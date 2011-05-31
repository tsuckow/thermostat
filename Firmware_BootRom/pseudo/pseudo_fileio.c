/*--------------------------------------------------------------------------
 * Start of $Workfile: pseudo_fileio.c $
 *
 * File Description
 * ----------------
 *
 * Refer to pseudo_fileio.h
 *
 *-------------------------------------------------------------------------*/

#define MODULE_NAME "PSEUDO_FILEIO"
#define _PSEUDO_FILEIO_C_ 1

/*--------------------------------------------------------------------------
 * Included Headers
 *-------------------------------------------------------------------------*/

#include <unistd.h>
#include <stdio.h>
#include "pseudo_fileio.h"

/*--------------------------------------------------------------------------
 * Local #defines
 *-------------------------------------------------------------------------*/

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

#define NORMALISE_RANGE(min,max,value)  MAX((min),MIN((max),(value)))
 
/*--------------------------------------------------------------------------
 * Local Enums
 *-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
 * Local Structure Types
 *-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
 * Global Variables
 *-------------------------------------------------------------------------*/

/* int pseudo_errno = _PSEUDO_ENOERR;  0 == no error, other == error */
/*     ^^^^^^^^^^^^Just use errno, like everybody else? */

/*--------------------------------------------------------------------------
 * Local Variables
 *-------------------------------------------------------------------------*/

static PSEUDO_FILE _pseudo_iob[_PSEUDO_NFILE];
static int         _pseudo_init  = 0; /* 0 == not initialised, other == initialised */
static const char *_pseudo_errs[] =
{
/* _PSEUDO_ENOERR = 0,     */ "No error",
                           /* (Do not put errors ahead of this) */
/* _PSEUDO_ENOENT = 0xa1f, */ "No such file or directory",
/* _PSEUDO_ENXIO  ,        */ "No such device or address",
/* _PSEUDO_ECONTR ,        */ "Memory blocks destroyed",
/* _PSEUDO_EBADF  ,        */ "Bad file number",
/* _PSEUDO_EINVFMT,        */ "Invalid format",
/* _PSEUDO_EINVAL ,        */ "Invalid argument",
/* _PSEUDO_ENFILE ,        */ "Too many open files in system",
/* _PSEUDO_EMFILE ,        */ "Too many open files in process",
/* _PSEUDO_EROFS  ,        */ "Read only file system",
/* _PSEUDO_ERANGE ,        */ "Result too large",
/* _PSEUDO_EPERM  ,        */ "Operation not permitted",
/* _PSEUDO_EIO    ,        */ "Input/output error",
/* _PSEUDO_EBADFD ,        */ "f.d. invalid for this operation",

/* _PSEUDO_ELAST           */ "insert new errors ahead of this"
};
    

/*--------------------------------------------------------------------------
 * Local Function Prototypes
 *-------------------------------------------------------------------------*/

static void _pseudo_init_array(void);  /* Never fails */

/*--------------------------------------------------------------------------
 * Global Function Implementations
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/
PSEUDO_FILE *pseudo_fopen(const char *pointer, const long numbytes)
{
    PSEUDO_FILE *fp;

    if ( _pseudo_init == 0 )
    {
        _pseudo_init_array();
    }

    for ( fp = _pseudo_iob; fp < _pseudo_iob + _PSEUDO_NFILE; fp++ )
    {
        if ( fp->_flag == 0 )
            break; /* found free slot */
    }

    if ( fp >= _pseudo_iob + _PSEUDO_NFILE ) /* no free slots */
    {
        errno = _PSEUDO_EMFILE; /* Too many open files in process */
        return NULL;
    }

    fp->_base = (void *) pointer;
    fp->_size = numbytes;
    fp->_ptr  = fp->_base;
    fp->_flag = 1;
    fp->_err  = _PSEUDO_ENOERR; /* No error */

    return fp;
}

/*-------------------------------------------------------------------------*/
int pseudo_ferror(PSEUDO_FILE *fp)
{
    if ( _pseudo_init == 0 )
    {
        errno = _PSEUDO_EINVFMT; /* Invalid format */
        return errno;
    }

    if ( fp < _pseudo_iob || fp >= _pseudo_iob + _PSEUDO_NFILE )
    {
        errno = _PSEUDO_EBADF; /* Bad file number */
        return errno;
    }

    /* Probably being a bit too 'precious' here... Take this test out for time being... */
#if 0
    if ( fp->_flag != 0 ) /* file 'open'? */
    {
        errno = _PSEUDO_EBADFD; /* f.d. invalid for this operation */
        return errno;
    }
#endif

    return fp->_err;
}

/*-------------------------------------------------------------------------*/
void pseudo_clearerr(PSEUDO_FILE *fp)
{
    if ( _pseudo_init == 0 )
    {
        errno = _PSEUDO_EINVFMT; /* Invalid format */
        return;
    }

    if ( fp < _pseudo_iob || fp >= _pseudo_iob + _PSEUDO_NFILE )
    {
        errno = _PSEUDO_EBADF; /* Bad file number */
        return;
    }

    /* Probably being a bit too 'precious' here... Take this test out for time being... */
#if 0
    if ( fp->_flag != 0 ) /* file 'open'? */
    {
        errno = _PSEUDO_EBADFD; /* f.d. invalid for this operation */
        return;
    }
#endif

    fp->_err = _PSEUDO_ENOERR;
}

/*-------------------------------------------------------------------------*/
char *pseudo_strerror(int errnum)
{
    static char dummy [] = "Unknown error xxxxxxxxxxxxx";

    if ( _PSEUDO_ENOERR == errnum )
        return (char*)_pseudo_errs[_PSEUDO_ENOERR];

    if ( errnum < _PSEUDO_ENOENT || errnum >= _PSEUDO_ELAST )
    {
        sprintf(&dummy[14],"%d",errnum);
        return dummy;
    }

    return (char*)_pseudo_errs[errnum - _PSEUDO_ENOENT + 1];
}

/*-------------------------------------------------------------------------*/
size_t pseudo_fread(void *ptr, size_t size, size_t n, PSEUDO_FILE *fp)
{
    long remaining = 0L;
    long requested = 0L;

/*  printf("pseudo_fread %d fp=%p ptr=%p size=%d n=%d", __LINE__, fp, ptr, size, n); */

    if ( _pseudo_init == 0 )
    {
        errno = _PSEUDO_EINVFMT; /* Invalid format */
        printf("pseudo_fread %d errno=%d=\"%s\"", __LINE__, errno, pseudo_strerror(errno));
        return (size_t)0;
    }

    if ( fp < _pseudo_iob || fp >= _pseudo_iob + _PSEUDO_NFILE )
    {
        errno = _PSEUDO_EBADF; /* Bad file number */
        printf("pseudo_fread %d errno=%d=\"%s\"", __LINE__, errno, pseudo_strerror(errno));
        return (size_t)0;
    }

    if ( fp->_flag != 1 ) /* if file not 'open' for reading? */
    {
        fp->_err = errno = _PSEUDO_EBADFD; /* f.d. invalid for this operation */
        printf("pseudo_fread %d errno=%d=\"%s\"", __LINE__, errno, pseudo_strerror(errno));
        return (size_t)0;
    }

    /* file open: figure out how much there is left to 'read' */
    remaining = fp->_size - (long)((char*)fp->_ptr - (char*)fp->_base);
    if ( remaining <= 0L )
    {
        fp->_err = errno = _PSEUDO_EIO; /* Input/output error */
        printf("pseudo_fread %d errno=%d=\"%s\"", __LINE__, errno, pseudo_strerror(errno));
        return (size_t)0;
    }

    /* find out what can be supplied */
    requested = (long)size * (long)n;
    requested = NORMALISE_RANGE((long)0, remaining, requested);

    /* 'read' the file */
    memcpy(ptr, fp->_ptr, (int)requested);

    /* increment our 'position' within the 'file' */
    fp->_ptr = (void *)((char*)fp->_ptr + requested);

    return (size_t)requested;
}

/*-------------------------------------------------------------------------*/
void pseudo_rewind(PSEUDO_FILE *fp)
{
    if ( _pseudo_init == 0 )
    {
        errno = _PSEUDO_EINVFMT; /* Invalid format */
        return;
    }

    if ( fp < _pseudo_iob || fp >= _pseudo_iob + _PSEUDO_NFILE )
    {
        errno = _PSEUDO_EBADF; /* Bad file number */
        return;
    }

    if ( fp->_flag != 0 ) /* file 'open'? */
    {
        fp->_err = errno = _PSEUDO_EBADFD; /* f.d. invalid for this operation */
        return;
    }

    fp->_ptr  = fp->_base;
    fp->_err  = _PSEUDO_ENOERR; /* No error */
}

/*-------------------------------------------------------------------------*/
int pseudo_fclose(PSEUDO_FILE *fp)
{
    if ( _pseudo_init == 0 )
    {
        _pseudo_init_array();
    }

    if ( fp < _pseudo_iob || fp >= _pseudo_iob + _PSEUDO_NFILE )
    {
        errno = _PSEUDO_EBADF; /* Bad file number */
        return EOF;
    }

    if ( fp->_flag == 0 ) /* file 'open'? */
    {
        errno = _PSEUDO_EBADFD; /* f.d. invalid for this operation */
        return EOF;
    }

    fp->_base = (void *) NULL;
    fp->_size = 0L;
    fp->_ptr  = fp->_base;
    fp->_flag = 0;
    fp->_err  = _PSEUDO_ENOERR; /* No error */

    return 0;
}

/*--------------------------------------------------------------------------
 * Local Function Implementations
 *-------------------------------------------------------------------------*/

static void _pseudo_init_array(void) /* Never fails */
{
    PSEUDO_FILE *fp;

    if ( _pseudo_init == 0 )
    {
        for ( fp = _pseudo_iob; fp < _pseudo_iob + _PSEUDO_NFILE; fp++ )
        {
            fp->_base = NULL; /* location of buffer */
            fp->_size = 0L  ; /* 'size' of 'file' */
            fp->_ptr  = NULL; /* next character position */
            fp->_flag = 0   ; /* file access: 0=free, 1=read */
            fp->_err  = _PSEUDO_ENOERR; /* error flag: 0=OK, other=error */
        }
        _pseudo_init = 1;
        errno = _PSEUDO_ENOERR; /* No error */
    }
}

/* End of $Workfile: pseudo_fileio.c $ */

