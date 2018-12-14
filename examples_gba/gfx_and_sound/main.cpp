// This whole CMake system is based on: https://github.com/Lectem/3ds-cmake
// Thanks a lot for the template! I used bits and pieces from the CMake parts.
// It is under the MIT license, so I guess it is ok to leave this under the same license.
//
// To build from the command line: 
// mkdir build && cd build
// cmake .. -DCMAKE_TOOLCHAIN_FILE=DevkitArmGBA.cmake
// make -j 4
// 
// For Visual Studio Code:
// - Install the CMake extension ("CMake Tools" by "vector-of-bool") if you haven't yet. 
// - Choose "Unspecified" as your active CMake kit if asked. It will be autodetected correctly.
// - Make sure ".vscode/c_cpp_properties.json" contains the proper paths to your DevKitPro installation!
// - Make sure ".vscode/launch.json" points to a proper emulator on your system and your executable!
// - Make sure ".vscode/tasks.json" points your executable!
//   This seems a bit redundant, because CMake can build the binary just fine without it, 
//   but it is necessary for compiling on F5 to work, as the "build" command will be executed before launching.
//   If there's an easier way, I'd love to hear it.
// - You should be able to build using F7 and build + run using F5.

#include <gba_video.h>
#include <gba_dma.h>
#include <gba_systemcalls.h>

// For playing the sound
#include <gba_interrupt.h>
#include <maxmod.h>
#include "soundbank.h"
#include "soundbank_bin.h"

mm_sound_effect soundEffects[] = {{{SFX_SOUND}, 1 << 10, 0, 255, 128}};

// For drawing the logo
#include "memory.h"
#include "./data/dkp_logo.h"

int main()
{
	// MaxMOD requires the vblank interrupt to reset sound DMA, so link the VBlank interrupt to mmVBlank, and enable it.
	irqInit();
	irqSet(IRQ_VBLANK, mmVBlank);
	irqEnable(IRQ_VBLANK);
	// initialise MaxMOD with soundbank and 4 channels
	mmInitDefault((mm_addr)soundbank_bin, 4);
	// Set graphics to mode 4 and enable background 2 
	REG_DISPCNT = MODE_4 | BG2_ON;
	// copy data to palette and backbuffer
	Memory::memcpy32(BG_PALETTE, dkp_logo_palette, DKP_LOGO_PALETTE_SIZE >> 2);
	Memory::memcpy32(MODE5_BB, dkp_logo, DKP_LOGO_SIZE >> 2);
	// swap backbuffer
	REG_DISPCNT = REG_DISPCNT | BACKBUFFER;
	// start plaing sound and make sure MaxMOD keeps filling buffers
	mmEffectEx(&soundEffects[0]);
	do
	{	
		VBlankIntrWait();
		mmFrame();
	} while (true);
}
