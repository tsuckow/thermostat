
#include "filesystem.h"
#include "sd_spi.h"
#include "sd.h"
#include "dosfs.h"

uint8_t sector[SECTOR_SIZE], sector2[SECTOR_SIZE];
uint32_t pstart, psize, i;
uint8_t pactive, ptype;
VOLINFO vi;
DIRINFO di;
DIRENT de;
uint32_t cache;
FILEINFO fi;
uint8_t *p;

void efsl_debug(unsigned char const * format, ...);

void filesystem_init(void)
{
	printf("Init Filesystem\n");
	if_spiInit();
	sd_Init();
	
	pstart = DFS_GetPtnStart(0, sector, 0, &pactive, &ptype, &psize);
	if (pstart == 0xffffffff) {
		printf("Cannot find first partition\n");
		return;
	}
	
	efsl_debug("Partition 0 start sector 0x%-08.8lX active %-02.2hX type %-02.2hX size %-08.8lX\n", pstart, pactive, ptype, psize);

	if (DFS_GetVolInfo(0, sector, pstart, &vi)) {
		printf("Error getting volume information\n");
		return;
	}
	efsl_debug("Volume label '%-11.11s'\n", vi.label);
	efsl_debug("%d sector/s per cluster, %d reserved sector/s, volume total %d sectors.\n", vi.secperclus, vi.reservedsecs, vi.numsecs);
	efsl_debug("%d sectors per FAT, first FAT at sector #%d, root dir at #%d.\n",vi.secperfat,vi.fat1,vi.rootdir);
	efsl_debug("(For FAT32, the root dir is a CLUSTER number, FAT12/16 it is a SECTOR number)\n");
	efsl_debug("%d root dir entries, data area commences at sector #%d.\n",vi.rootentries,vi.dataarea);
	efsl_debug("%d clusters (%d bytes) in data area, filesystem IDd as \n", vi.numclusters, vi.numclusters * vi.secperclus * SECTOR_SIZE);
	if (vi.filesystem == FAT12)
		efsl_debug("FAT12.\n");
	else if (vi.filesystem == FAT16)
		efsl_debug("FAT16.\n");
	else if (vi.filesystem == FAT32)
		efsl_debug("FAT32.\n");
	else
		efsl_debug("[unknown]\n");
}
