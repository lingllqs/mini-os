#![no_std]  // 不使用标准库
#![no_main] // 不需要一般的main入口

use core::panic::PanicInfo;

/// 假设 framebuffer 起始地址（QEMU 1024x768 std VGA）
const FRAMEBUFFER_ADDR: usize = 0xb8000;

#[unsafe(no_mangle)]
pub extern "C" fn kernel_main() -> ! {
    let message = b"Hello from MiniOS!";
    let fb = FRAMEBUFFER_ADDR as *mut u16;

    unsafe {
        for (i, &c) in message.iter().enumerate() {
            // 16 位 VGA 文本模式，低字节 ASCII，高字节颜色
            // 0x0F: 黑底白字
            *fb.add(i) = (0x0F << 8) | c as u16;
        }
    }

    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

// #[used]
// #[unsafe(link_section = ".multiboot")]
// static MULTIBOOT2_HEADER: [u32; 8] = [
//     0xE85250D6, // magic
//     0,          // architecture
//     24,         // header length
//     0x100000000u64.wrapping_sub(0xE85250D6 + 24) as u32,
//     0,
//     8,
//     0,
//     0,
// ];
