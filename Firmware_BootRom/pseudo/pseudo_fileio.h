#if !defined (__PSEUDO_FILEIO_H__)
#define       __PSEUDO_FILEIO_H__ 1
/*--------------------------------------------------------------------------
 * Start of $Workfile: pseudo_fileio.h $
 *
 * File Description
 * ----------------
 *
 * This is a straight mung from K&R, 1st Edition, "The C Programming Language",
 * section 8.5 "Example - An Implementation of Fopen and Getc"
 *
 * This is a "pseudo" file IO library: in fact it's even simpler than that,
 * because only file "reading" has been implemented to date (2003-05-15).
 *
 * This library provides the following pseudo file functions:
 *
 *     pseudo_fopen()
 *     pseudo_ferror()
 *     pseudo_clearerr()
 *     pseudo_strerror()
 *     pseudo_fread()
 *     pseudo_rewind()
 *     pseudo_fclose()
 *
 * as well as the definition for the pseudo file 'handle':
 *
 *     PSEUDO_FILE
 *
 * The routines can open a default maximum of _PSEUDO_NFILE files and are safe
 * in a 'global' environment such as AMX.
 *
 *-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
 * Global #defines
 *-------------------------------------------------------------------------*/

#ifndef _PSEUDO_NFILE
#define _PSEUDO_NFILE 5 /* number of pseudo files that can be opened (K&R has 20) */
#endif

/* Use this if you don't know the size of the largest pseudo-file.  At 20030502,
 * pseudo-files are only used for pictures, and the largest, at 20030502 is
 * 30725, allow for about 3 times this...
 */
#ifndef _PSEUDO_FILE_MAX_SIZE
#define _PSEUDO_FILE_MAX_SIZE 100000
#endif

/* short selection of errnos ... */
enum _pseudo_errno_tag
{
    _PSEUDO_ENOERR = 0,     /* No error */
                            /* (Do not put errors ahead of this) */
    _PSEUDO_ENOENT = 0xa1f, /* No such file or directory */
    _PSEUDO_ENXIO  ,        /* No such device or address */
    _PSEUDO_ECONTR ,        /* Memory blocks destroyed */
    _PSEUDO_EBADF  ,        /* Bad file number */
    _PSEUDO_EINVFMT,        /* Invalid format */
    _PSEUDO_EINVAL ,        /* Invalid argument */
    _PSEUDO_ENFILE ,        /* Too many open files in system */
    _PSEUDO_EMFILE ,        /* Too many open files in process */
    _PSEUDO_EROFS  ,        /* Read only file system */
    _PSEUDO_ERANGE ,        /* Result too large */
    _PSEUDO_EPERM  ,        /* Operation not permitted */
    _PSEUDO_EIO    ,        /* Input/output error */
    _PSEUDO_EBADFD ,        /* f.d. invalid for this operation */

    _PSEUDO_ELAST           /* insert new errors ahead of this */
};


/*--------------------------------------------------------------------------
 * Global Enums
 *-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
 * Global Structure Types
 *-------------------------------------------------------------------------*/

typedef struct _pseudo_iobuf
{
    void *_base; /* location of buffer */
    long  _size; /* 'size' of 'file' */
    void *_ptr ; /* next character position */
    int   _flag; /* file access: 0=free, 1=read */
    int   _err ; /* error flag: 0=OK, other=error */
}
    PSEUDO_FILE;

/*--------------------------------------------------------------------------
 * Global Function Prototypes
 *-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
 * Description:
 *     Opens a pseudo stream.
 *
 * 'pseudo_fopen()' opens the 'file' pointed to by 'pointer' and associates a
 * pseudo stream with it. 'pseudo_fopen()' returns a pointer to be used to
 * identify the pseudo stream in subsequent operations.
 *
 * Because we are not opening a real file, we have to supply the file size to
 * the 'pseudo_fopen()' routine.  Ie, we cannot query the file 'system' for the
 * file's size.
 *
 * If the file size is not known, to limit damage which may result, pass a
 * number larger than any known pseduo file, for example, 1Mbyte. ***USE WITH
 * CAUTION***
 *
 * Return Value:
 *     On successful completion 'pseudo_fopen()' returns a pointer to the newly
 *     opened pseudo stream. In the event of error it returns NULL.
 */
PSEUDO_FILE *pseudo_fopen(const char *pointer, const long numbytes);

/*--------------------------------------------------------------------------
 * Description
 *     Detects errors on the pseudo stream. This tests the given pseudo stream
 *     for a read or write error. If the pseudo stream's error indicator has
 *     been set it remains set until pseudo_clearerr() or pseudo_rewind() is
 *     called or until the pseudo stream is closed.
 *
 * Return Value
 *     _PSEUDO_EINVFMT "Invalid format" if pseudo_fopen() or
 *                     pseudo_fclose() have never been called.  These
 *                     two routines set up the pseudo streams table.
 *     _PSEUDO_EBADF   "Bad file number" if fp isn't in the pseudo
 *                     streams table.
 *     0               if no error has been detected
 *     other           if an error was detected on the named pseudo stream.
 */
int pseudo_ferror(PSEUDO_FILE *fp);

/*--------------------------------------------------------------------------
 * Description
 *     Resets error indication.  pseudo_clearerr() resets the named pseudo
 *     stream's error indicator to 0. Once the error indicator is set, pseudo
 *     stream operations continue to return error status until a call is made
 *     to pseudo_clearerr() or pseudo_rewind().
 *
 * Return Value
 *     None.
 *
 * Side Effects
 *     errno set to:
 *         _PSEUDO_EINVFMT "Invalid format" if pseudo_fopen()
 *                         or pseudo_fclose() have never been called.  These
 *                         two routines set up the pseudo streams table.
 *         _PSEUDO_EBADF   "Bad file number" if fp isn't in the pseudo
 *                         streams table.
 */
void pseudo_clearerr(PSEUDO_FILE *fp);

/*--------------------------------------------------------------------------
 * Description
 *     Returns a pointer to an error message string.
 *
 *     strerror takes an int parameter errnum, an error number, and returns a
 *     pointer to an error message string associated with errnum.
 *
 * Return Value
 *     strerror returns a pointer to a constant error string.
 */
char *pseudo_strerror(int errnum);

/*--------------------------------------------------------------------------
 * Description:
 *     Reads data from a pseudo stream.
 *
 * 'pseudo_fread()' reads 'n' items of data each of length 'size' bytes from
 * the given input pseudo stream into a block pointed to by ptr.
 *
 * The total number of bytes read is (n * size).
 *
 * Warning: if numbytes was less than zero on the pseudo_fopen() call, then
 * there is no check for overrun until the file size has exceeded 1 Mbyte.

 *
 * Return Value:
 *     On success fread returns the number of items (not bytes) actually read.
 *
 *     On end-of-file or error it returns a short count (possibly 0).
 */
size_t pseudo_fread(void *ptr, size_t size, size_t n, PSEUDO_FILE *fp);

/*--------------------------------------------------------------------------
 * Description
 *     Repositions a file pointer to the beginning of a pseudo stream.
 *     pseudo_rewind(pseudo_stream) clears the file's error indicator.
 *
 * Return Value
 *     None.
 *
 * Side Effects
 *     errno set to:
 *         _PSEUDO_EINVFMT "Invalid format" if pseudo_fopen()
 *                         or pseudo_fclose() have never been called.  These
 *                         two routines set up the pseudo streams table.
 *         _PSEUDO_EBADF   "Bad file number" if fp isn't in the pseudo
 *                         streams table.
 *         _PSEUDO_EBADFD  "f.d. invalid for this operation" ie, file not open
 */
void pseudo_rewind(PSEUDO_FILE *fp);

/*--------------------------------------------------------------------------
 * Description:
 *     Closes a pseudo stream.
 *
 * 'pseudo_fclose()' closes the named pseudo stream.
 *
 * Return Value:
 *     'pseudo_fclose()' returns 0 on success.
 *
 *     It returns EOF if any errors were detected.
 *
 * Side Effects
 *     errno set to:
 *         _PSEUDO_EBADF   "Bad file number" if fp isn't in the pseudo
 *                         streams table.
 *         _PSEUDO_EBADFD  "f.d. invalid for this operation" ie, file not open
 */
int pseudo_fclose(PSEUDO_FILE *fp);

/*--------------------------------------------------------------------------
 * Global Variables
 *-------------------------------------------------------------------------*/

/* extern int pseudo_errno; */
extern int errno;


/*-------------------------------------------------------------------------*/

#endif /* !defined (__PSEUDO_FILEIO_H__) */

/* End of $Workfile: pseudo_fileio.h $ */

