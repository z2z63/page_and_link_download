// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.28.

#![allow(
    non_camel_case_types,
    unused,
    non_snake_case,
    clippy::needless_return,
    clippy::redundant_closure_call,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::unused_unit,
    clippy::double_parens,
    clippy::let_and_return,
    clippy::too_many_arguments,
    clippy::match_single_binding
)]

// Section: imports

use flutter_rust_bridge::for_generated::byteorder::{NativeEndian, ReadBytesExt, WriteBytesExt};
use flutter_rust_bridge::for_generated::transform_result_dco;
use flutter_rust_bridge::{Handler, IntoIntoDart};

// Section: boilerplate

flutter_rust_bridge::frb_generated_boilerplate!(
    default_stream_sink_codec = SseCodec,
    default_rust_opaque = RustOpaqueMoi,
    default_rust_auto_opaque = RustAutoOpaqueMoi,
);
const FLUTTER_RUST_BRIDGE_CODEGEN_VERSION: &str = "2.0.0-dev.28";

// Section: executor

flutter_rust_bridge::frb_generated_default_handler!();

// Section: wire_funcs

fn wire_Response_text_impl(
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) -> flutter_rust_bridge::for_generated::WireSyncRust2DartSse {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_sync::<flutter_rust_bridge::for_generated::SseCodec, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Response_text",
            port: None,
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Sync,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <crate::api::simple::Response>::sse_decode(&mut deserializer);
            deserializer.end();
            transform_result_sse((move || crate::api::simple::Response::text(&api_that))())
        },
    )
}
fn wire_get_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_async::<flutter_rust_bridge::for_generated::SseCodec, _, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "get",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_url = <String>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| async move {
                transform_result_sse(
                    (move || async move { crate::api::simple::get(api_url).await })().await,
                )
            }
        },
    )
}
fn wire_greet_impl(
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) -> flutter_rust_bridge::for_generated::WireSyncRust2DartSse {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_sync::<flutter_rust_bridge::for_generated::SseCodec, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "greet",
            port: None,
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Sync,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_name = <String>::sse_decode(&mut deserializer);
            deserializer.end();
            transform_result_sse((move || {
                Result::<_, ()>::Ok(crate::api::simple::greet(api_name))
            })())
        },
    )
}
fn wire_init_app_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "init_app",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            deserializer.end();
            move |context| {
                transform_result_sse(
                    (move || Result::<_, ()>::Ok(crate::api::simple::init_app()))(),
                )
            }
        },
    )
}

// Section: dart2rust

impl SseDecode for String {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <Vec<u8>>::sse_decode(deserializer);
        return String::from_utf8(inner).unwrap();
    }
}

impl SseDecode for i32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_i32::<NativeEndian>().unwrap()
    }
}

impl SseDecode for Vec<String> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<String>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<u8> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<u8>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for crate::api::simple::NetworkError {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_reason = <String>::sse_decode(deserializer);
        return crate::api::simple::NetworkError { reason: var_reason };
    }
}

impl SseDecode for crate::api::simple::Response {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_status = <i32>::sse_decode(deserializer);
        let mut var_headers = <Vec<String>>::sse_decode(deserializer);
        let mut var_body = <Vec<u8>>::sse_decode(deserializer);
        return crate::api::simple::Response {
            status: var_status,
            headers: var_headers,
            body: var_body,
        };
    }
}

impl SseDecode for u8 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u8().unwrap()
    }
}

impl SseDecode for () {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {}
}

impl SseDecode for crate::api::simple::Utf8DecodeError {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        return crate::api::simple::Utf8DecodeError {};
    }
}

impl SseDecode for bool {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u8().unwrap() != 0
    }
}

fn pde_ffi_dispatcher_primary_impl(
    func_id: i32,
    port: flutter_rust_bridge::for_generated::MessagePort,
    ptr: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len: i32,
    data_len: i32,
) {
    // Codec=Pde (Serialization + dispatch), see doc to use other codecs
    match func_id {
        3 => wire_get_impl(port, ptr, rust_vec_len, data_len),
        2 => wire_init_app_impl(port, ptr, rust_vec_len, data_len),
        _ => unreachable!(),
    }
}

fn pde_ffi_dispatcher_sync_impl(
    func_id: i32,
    ptr: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len: i32,
    data_len: i32,
) -> flutter_rust_bridge::for_generated::WireSyncRust2DartSse {
    // Codec=Pde (Serialization + dispatch), see doc to use other codecs
    match func_id {
        4 => wire_Response_text_impl(ptr, rust_vec_len, data_len),
        1 => wire_greet_impl(ptr, rust_vec_len, data_len),
        _ => unreachable!(),
    }
}

// Section: rust2dart

// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::simple::NetworkError {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [self.reason.into_into_dart().into_dart()].into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::simple::NetworkError
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::simple::NetworkError>
    for crate::api::simple::NetworkError
{
    fn into_into_dart(self) -> crate::api::simple::NetworkError {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::simple::Response {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.status.into_into_dart().into_dart(),
            self.headers.into_into_dart().into_dart(),
            self.body.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::simple::Response {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::simple::Response>
    for crate::api::simple::Response
{
    fn into_into_dart(self) -> crate::api::simple::Response {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::simple::Utf8DecodeError {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        Vec::<u8>::new().into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::simple::Utf8DecodeError
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::simple::Utf8DecodeError>
    for crate::api::simple::Utf8DecodeError
{
    fn into_into_dart(self) -> crate::api::simple::Utf8DecodeError {
        self
    }
}

impl SseEncode for String {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<u8>>::sse_encode(self.into_bytes(), serializer);
    }
}

impl SseEncode for i32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_i32::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for Vec<String> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <String>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<u8> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <u8>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for crate::api::simple::NetworkError {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.reason, serializer);
    }
}

impl SseEncode for crate::api::simple::Response {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.status, serializer);
        <Vec<String>>::sse_encode(self.headers, serializer);
        <Vec<u8>>::sse_encode(self.body, serializer);
    }
}

impl SseEncode for u8 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u8(self).unwrap();
    }
}

impl SseEncode for () {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {}
}

impl SseEncode for crate::api::simple::Utf8DecodeError {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {}
}

impl SseEncode for bool {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u8(self as _).unwrap();
    }
}

#[cfg(not(target_family = "wasm"))]
#[path = "frb_generated.io.rs"]
mod io;
#[cfg(not(target_family = "wasm"))]
pub use io::*;

/// cbindgen:ignore
#[cfg(target_family = "wasm")]
#[path = "frb_generated.web.rs"]
mod web;
#[cfg(target_family = "wasm")]
pub use web::*;
