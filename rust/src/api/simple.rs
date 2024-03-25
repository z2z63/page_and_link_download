#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

use std::fmt::{Debug, Formatter};
use std::{fmt, io};
use std::io::{BufRead, Read};
use bytes::Buf;
use futures::{AsyncReadExt, AsyncWriteExt};
use url::Url;
use async_tls;
use async_std;

enum HTTPSchema {
    HTTP,
    HTTPS,
}

impl HTTPSchema {
    fn from_string(schema: &str) -> HTTPSchema {
        match schema {
            "http" => HTTPSchema::HTTP,
            "https" => HTTPSchema::HTTPS,
            _ => panic!("unsupported schema: {}", schema),
        }
    }
}

enum HTTPMethod {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD,
    OPTIONS,
    CONNECT,
    TRACE,
    PATCH,
}

impl HTTPMethod {
    fn to_string(&self) -> String {
        match self {
            HTTPMethod::GET => String::from("GET"),
            HTTPMethod::POST => String::from("POST"),
            HTTPMethod::PUT => String::from("PUT"),
            HTTPMethod::DELETE => String::from("DELETE"),
            HTTPMethod::HEAD => String::from("HEAD"),
            HTTPMethod::OPTIONS => String::from("OPTIONS"),
            HTTPMethod::CONNECT => String::from("CONNECT"),
            HTTPMethod::TRACE => String::from("TRACE"),
            HTTPMethod::PATCH => String::from("PATCH"),
        }
    }
    fn from_string(method: &str) -> HTTPMethod {
        match method {
            "GET" => HTTPMethod::GET,
            "POST" => HTTPMethod::POST,
            "PUT" => HTTPMethod::PUT,
            "DELETE" => HTTPMethod::DELETE,
            "HEAD" => HTTPMethod::HEAD,
            "OPTIONS" => HTTPMethod::OPTIONS,
            "CONNECT" => HTTPMethod::CONNECT,
            "TRACE" => HTTPMethod::TRACE,
            "PATCH" => HTTPMethod::PATCH,
            _ => panic!("unsupported method: {}", method),
        }
    }
}

pub struct Request {
    url: String,
    schema: HTTPSchema,
    host: String,
    port: u16,
    path: String,
    method: HTTPMethod,
    headers: Vec<String>,
    pub body: Vec<u8>,
}

impl Request {
    fn new(method: HTTPMethod, url: &str) -> Request {
        let mut headers = vec![];
        let parsed_url = Url::parse(url).unwrap();
        let host = parsed_url.host().expect(format!("host not found: {}", url).as_str()).to_string();
        let schema = parsed_url.scheme();
        let schema = HTTPSchema::from_string(schema);
        let port = parsed_url.port().unwrap_or(
            match schema {
                HTTPSchema::HTTP => 80,
                HTTPSchema::HTTPS => 443
            }
        );
        let path = parsed_url.path();
        headers.push(format!("Host: {}:{}", host, port));
        return Request {
            url: String::from(url),
            schema,
            host,
            port,
            path: String::from(path),
            method,
            headers,
            body: vec![],
        };
    }

    async fn send(self) -> io::Result<Response> {
        let packet = [
            format!("{} {} HTTP/1.0\r\n", self.method.to_string(), self.path).as_bytes(),
            self.headers.join("\r\n").as_bytes(),
            b"\r\n\r\n", self.body.as_slice(),
        ].concat();
        let addr = format!("{}:{}", self.host, self.port);
        return match self.schema {
            HTTPSchema::HTTPS => {
                let stream = async_std::net::TcpStream::connect(format!("{}:{}", self.host, self.port)).await?;
                let connector = async_tls::TlsConnector::default();
                let mut tls_stream = connector.connect(self.host, stream).await?;
                tls_stream.write_all(packet.as_slice()).await?;
                let mut body = vec![];
                tls_stream.read_to_end(&mut body).await.unwrap_or(0);   // 处理eof
                Ok(Response::from_bytes(body))
            }
            HTTPSchema::HTTP => {
                let mut stream = async_std::net::TcpStream::connect(addr.as_str()).await?;
                stream.write_all(packet.as_slice()).await?;
                let mut body = vec![];
                stream.read_to_end(&mut body).await?;
                Ok(Response::from_bytes(body))
            }
        };
    }
}

pub async fn get(url: String) -> Result<Response, NetworkError> {
    const MAX_REDIRECT_TIMES: i32 = 20;
    let mut redirect_times = 0;
    let mut location = url;
    while redirect_times < MAX_REDIRECT_TIMES {
        let resp = single_get(location.as_str()).await?;
        if resp.status != 301 {
            return Ok(resp);
        }
        redirect_times += 1;
        location = resp.headers.iter().
            find(|line| line.starts_with("Location: "))
            .unwrap().trim()
            .strip_prefix("Location:").unwrap().trim().to_string();
    }
    Err(NetworkError {
        reason: "redirect too many times".to_string(),
    })
}

async fn single_get(url: &str) -> Result<Response, NetworkError> {
    let req = Request::new(HTTPMethod::GET, url);
    let resp = req.send().await;
    return match resp {
        Ok(resp) => {
            Ok(resp)
        }
        Err(e) => {
            Err(NetworkError {
                reason: e.to_string(),
            })
        }
    };
}

pub struct Response {
    pub status: i32,
    pub headers: Vec<String>,
    pub body: Vec<u8>,
}

impl Response {
    fn new(status: i32, headers: Vec<String>, body: Vec<u8>) -> Response {
        return Response {
            status,
            headers,
            body,
        };
    }

    fn from_bytes(bytes: Vec<u8>) -> Response {
        let mut reader = bytes.reader();
        let mut headers = vec![];

        let mut buf = vec![];
        let mut line_number = 0;
        let mut status = 0;
        // stop at \r\n\r\n
        while reader.read_until(b'\n', &mut buf).unwrap() > 2 {
            let line = buf.strip_suffix(&[b'\r', b'\n']).expect("no crlf");
            if line_number == 0 {
                let status_line = String::from_utf8(line.to_vec()).unwrap();
                // HTTP/1.1 301 Moved Permanently
                status = str::parse(&status_line[9..12]).unwrap();
            } else {
                headers.push(String::from_utf8(line.to_vec()).unwrap());
            }
            buf.clear();
            line_number += 1;
        }
        // remaining is body
        let mut body = vec![];
        reader.read_to_end(&mut body).unwrap();

        return Response::new(status, headers, body);
    }
    #[flutter_rust_bridge::frb(sync)]
    pub fn text(&self) -> Result<String, Utf8DecodeError> {
        match String::from_utf8(self.body.clone()) {
            Ok(data) => { Ok(data) }
            Err(_) => { Err(Utf8DecodeError {}) }
        }
    }
}

pub struct Utf8DecodeError {}

impl Debug for Utf8DecodeError {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "utf8 decode error")
    }
}

pub struct NetworkError {
    pub reason: String,
}

impl Debug for NetworkError {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "network error")
    }
}