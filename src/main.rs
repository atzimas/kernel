#![no_main]
#![no_std]

use limine::{
    BaseRevision,
    request::{RequestsEndMarker, RequestsStartMarker},
};

mod panic;

/// Definitions for the start and end for the Limine requests section.
#[used]
#[unsafe(link_section = ".requests_start_marker")]
static _START_MARKER: RequestsStartMarker = RequestsStartMarker::new();

#[used]
#[unsafe(link_section = ".requests_end_marker")]
static _END_MARKER: RequestsEndMarker = RequestsEndMarker::new();

/// Request for the base revision of the Limine protocol.
#[used]
#[unsafe(link_section = ".requests")]
static BASE_REVISION: BaseRevision = BaseRevision::new();

#[unsafe(no_mangle)]
unsafe extern "C" fn kernel_start() -> ! {
    assert!(BASE_REVISION.is_supported());

    loop {}
}
