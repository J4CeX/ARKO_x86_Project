#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#pragma pack(push, 1)
typedef struct {
    uint16_t type;
    uint32_t size;
    uint16_t reserved1;
    uint16_t reserved2;
    uint32_t offset;
} BMPHeader;

typedef struct {
    uint32_t size;
    int32_t width;
    int32_t height;
    uint16_t planes;
    uint16_t bpp;
    uint32_t compression;
    uint32_t imageSize;
    int32_t xppm;
    int32_t yppm;
    uint32_t clrUsed;
    uint32_t clrImportant;
} DIBHeader;
#pragma pack(pop)

void *load_bmp_pixels(const char *filename, uint32_t *width, uint32_t *height, uint32_t *offset, uint8_t **raw_buf) {
    FILE *f = fopen(filename, "rb");
    if (!f) {
        perror("Błąd otwierania pliku");
        return NULL;
    }

    BMPHeader bmp;
    DIBHeader dib;
    fread(&bmp, sizeof(bmp), 1, f);
    fread(&dib, sizeof(dib), 1, f);

    if (bmp.type != 0x4D42 || dib.bpp != 24) {
        fprintf(stderr, "Nieobsługiwany format BMP\n");
        fclose(f);
        return NULL;
    }

    *width = dib.width;
    *height = dib.height;
    *offset = bmp.offset;

    *raw_buf = malloc(bmp.size);
    fseek(f, 0, SEEK_SET);
    fread(*raw_buf, bmp.size, 1, f);
    fclose(f);

    return *raw_buf + *offset;
}

// Funkcja do przekształcania
void colormask(void *img, uint32_t width, uint32_t height,
               void *mask_img, uint32_t mask_width, uint32_t mask_height,
               uint32_t x, uint32_t y,
               uint32_t color1, uint32_t color2, uint32_t color3);

int main(int argc, char *argv[]) {
    if (argc != 6) {
        fprintf(stderr, "Użycie: %s x y color1 color2 color3 (kolory w hex)\n", argv[0]);
        return 1;
    }

    uint32_t x = (uint32_t)strtoul(argv[1], NULL, 10); // Wczytaj x jako dziesiętną
    uint32_t y = (uint32_t)strtoul(argv[2], NULL, 10); // Wczytaj y jako dziesiętną
    uint32_t color1 = (uint32_t)strtoul(argv[3], NULL, 16); // color1 w hex (np. 0xFF0000)
    uint32_t color2 = (uint32_t)strtoul(argv[4], NULL, 16); // color2 w hex (np. 0x00FF00)
    uint32_t color3 = (uint32_t)strtoul(argv[5], NULL, 16); // color3 w hex (np. 0x0000FF)

    uint32_t width, height, offset;
    uint8_t *img_buf;
    void *img = load_bmp_pixels("img.bmp", &width, &height, &offset, &img_buf);
    if (!img) return 1;

    uint32_t mwidth, mheight, moffset;
    uint8_t *mask_buf;
    void *mask_img = load_bmp_pixels("mask_img.bmp", &mwidth, &mheight, &moffset, &mask_buf);
    if (!mask_img) return 1;

    colormask(img, width, height,
              mask_img, mwidth, mheight,
              x, y,
              color1, color2, color3);

    FILE *out = fopen("img.bmp", "wb");
    if (!out) {
        perror("Błąd zapisu");
        return 1;
    }
    int row_bytes = ((width * 3 + 3) & ~3);
    fwrite(img_buf, 1, offset + row_bytes * height, out);
    fclose(out);

    free(img_buf);
    free(mask_buf);

    return 0;
}
