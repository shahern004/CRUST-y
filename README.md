# CRUST-y
Researching ways to use Rust for memory safety within a C++ baremetal binary

Building with g++ using mingw32-make

Reference Code:

main.cpp

```main.cpp
#ifdef _cplusplus
extern "C"
{
extern void delay(unsigned int delayTicks);

#include <stdint.h>
extern uint32_t answer_from_rust();
extern uint32_t* rust_get_array(uint32_t* len);

}
#endif

//
// FUNCTION: main
//
int main( void )
{
    printf("//********nHELLO CRUSTY MAIN\n//********");
    printf("\trust_function %d\n", answer_from_rust());
    uint32_t len = 0;
    printf("RustArray:");
    const uint32_t* rust_array = rust_get_array(&len);
    for(int i = 0; i < len; i++) printf("\t%08X", rust_array[i]);
    printf("\n\n");

    //Start FPGA
    initializeCfpga();

#endif

    launchApplication();
}
```

lib.rs

```rust
#![no_std]
#![no_main]

extern crate core;
use core::panic::PanicInfo;
use core::slice;

#[panic_handler]
fn panic (_info: &PanicInfo) -> !{
    loop{}
}

static mut ANSWER: u32= 20;

#[unsafe(no_mangle)]
pub extern "C" fn answer_from_rust() ->u32 {
    unsafe{
        ANSWER += 1;
        return ANSWER
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rust_get_array(len: *mut u32 ) -> *const u32 {
    let array: &[u32] = &[ 10,20,0xFACE,0x8008];
    unsafe{
        if !len.is_null() {
            *len = array.len() as u32;
        }
    }
    array.as_ptr()
}

fn read_mem_loc(address: *const u32 )->u16 {
    let address_ptr = address as *const u16;
    unsafe {
        *address_ptr
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn crusty_grab_msg_word_count( base_address: u32 ) -> u16 {

    // cmd fifo address
    let message_count_address = base_address + 0x12;
    let bytes_in_u16=2;
    let message_count:16 = read_mem_loc(message_count_address as *const u32) * bytes_in_u16;

    return message_count;
}

#[unsafe(no_mangle)]
pub extern "C" fn rust_read_message(base_address: u32, data: *mut u16, data_len: u16 )->u16 {
    // cmd fifo address
    let read_message = base_address + 0x40 ;

    let mut fifo_count:u16;
    let data_to_read: u16 = data_len as u16 / 2;
    let read_extra_byte: u16 = (data_len as u16) % 2;

    let mut size_read:u16 = 0;
    let i: usize = 0;

    if 0 < data_len
    {
        let slice;

        unsafe
        {
        slice = slice::from_raw_parts_mut(data, data_len as usize);
        }

        fifo_count = crusty_grab_msg_word_count(base_address);

        let mut words_to_read:u16 = data_to_read;

        if fifo_count < data_to_read
        {
            words_to_read = fifo_count;
        }
        for i in 0..words_to_read as usize
        {
            slice[i] = read_mem_loc(read_message as *const u32);
            size_read += 2;
        }

        fifo_count = crusty_grab_msg_word_count(base_address)

        if read_extra_byte == 1 && fifo_count > read_extra_byte as u16
        {
            slice[i] = read_mem_loc(read_message as *const u32);
            size_read = size_read + 1;
        }
    }
    else
    {
        size_read = 0;
    }
    
    return size_read;
}
```
