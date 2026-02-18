#ifndef GULI_FILE_H
#define GULI_FILE_H

/* Load file contents as a null-terminated string. Returns malloc'd buffer; caller must free.
   Returns NULL on failure (file not found, read error, etc.). */
char* GuliLoadFileText(const char* path);

#endif // GULI_FILE_H
