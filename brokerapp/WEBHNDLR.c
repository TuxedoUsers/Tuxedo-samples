/*	(c) 2003 BEA Systems, Inc. All Rights Reserved. */
/*	Copyright (c) 1997 BEA Systems, Inc.
  	All rights reserved

  	THIS IS UNPUBLISHED PROPRIETARY
  	SOURCE CODE OF BEA Systems, Inc.
  	The copyright notice above does not
  	evidence any actual or intended
  	publication of such source code.
*/

/* #ident	"@(#) samples/atmi/simpapp/simpserv.c	$Revision: 1.3 $" */

#include <stdio.h>
#include <ctype.h>
#include <atmi.h>	/* TUXEDO Header File */
#include <userlog.h>	/* TUXEDO Header File */

#include "http.fml32.h"

#include <sys/socket.h>
#include <sys/un.h>
#include <fcntl.h>
#include <stdlib.h>

#include <errno.h>

#include <php_embed.h>

#define SERVER_BUFSIZE 8192

#ifndef timersub
#define	timersub(a, b, result)                              \
do {                                                  \
    (result)->tv_sec = (a)->tv_sec - (b)->tv_sec;           \
    (result)->tv_usec = (a)->tv_usec - (b)->tv_usec;        \
    if ((result)->tv_usec < 0) {                            \
        --(result)->tv_sec;                                 \
        (result)->tv_usec += 1000000;                       \
    }                                                       \
} while (0)
#endif

typedef struct context {
  int request_processed;
} context;

/* Globals */
char *phpBuf;
char *response;
char *inbuf = NULL;
int read_post;
long gPos;

int my_php_ub_write(const char *str, unsigned int str_length TSRMLS_DC) {
  context *ctx = SG(server_context);

  /*
  userlog("my_php_ub_write %p", ctx);
  userlog("length is: %d", str_length);

  userlog("content: %s", str);
  */

  userlog("gPos: %d, str_length: %d", gPos, str_length);
  memcpy(response + gPos, str, str_length);

  gPos += str_length;
  
  return str_length;
}

void my_php_ub_flush(void *server_context) {
  context *ctx = server_context;

  TSRMLS_FETCH();

  if (ctx == NULL) { /*printf("flush - context null\n");*/ return; }

  /*  printf("print done, flush called %d\n", ctx == NULL ? 0 : ctx->request_processed);*/
}

static void
register_variable(long field, zval *vars_array)
{
    TSRMLS_FETCH();
    char val[1024];
    long len;
    int rc;

    len = sizeof(val);
    rc = Fget32((FBFR32 *)inbuf, field, 0, (char *)val, &len);
    if (rc < 0) {
        userlog("Problem getting %s: %s", Fname32(field), Fstrerror32(Ferror32)); 
    } else {
        if (field == SCRIPT_NAME) {
	    php_register_variable_safe("PHP_SELF", 
				       val, 
				       len - 1, 
				       vars_array TSRMLS_CC);
	    userlog("Registering: %s, %s", "PHP_SELF", val);
	} 
	php_register_variable_safe(Fname32(field), 
				   val, 
				   len - 1, 
				   vars_array TSRMLS_CC);
	userlog("Registering: %s, %s", Fname32(field), val);
    }
}

static char *
my_php_read_cookies(TSRMLS_D)
{
    const char *http_cookie;
    long len;
    int rc;
	
    /* TODO: handle de-alloc */
    http_cookie = malloc(1024);

    rc = Fget32((FBFR32 *)inbuf, HTTP_COOKIE, 0, (char *)http_cookie, &len);
    if (rc < 0) {
        userlog("Problem getting HTTP_COOKIE: %s", Fstrerror32(Ferror32)); 
	
	return NULL;
    } else {
        userlog("setting HTTP_COOKIE: %s", http_cookie); 

        return (char *) http_cookie;
    }
}

static int
my_php_header_handler(sapi_header_struct *sapi_header, sapi_header_op_enum op, sapi_headers_struct *sapi_headers TSRMLS_DC)
{
    char *val, *ptr;
    int ret;

    userlog("header_handler called");

    switch (op) {
        case SAPI_HEADER_DELETE:
	    userlog("header delete");
	    return 0;
	
        case SAPI_HEADER_DELETE_ALL:
	    userlog("header delete");
	    return 0;


        case SAPI_HEADER_ADD:
        case SAPI_HEADER_REPLACE:
	    userlog("header add or replace: %s", sapi_header->header);

	    val = strchr(sapi_header->header, ':');

	    if (!val) {
	        return 0;
	    }
	    ptr = val;

	    *val = '\0';
	    
	    do {
	        val++;
	    } while (*val == ' ');

	    if (!strcasecmp(sapi_header->header, "location")) {
	        ret = Fchg32((FBFR32 *)phpBuf, LOCATION, 0, val, strlen(val));
		if (ret < 0) {
		    userlog("Problem setting location in return buffer: %s", Fstrerror32(Ferror32));
		} else {
		    userlog("Set location %s in return buffer", val);
		}
	    } else if (!strcasecmp(sapi_header->header, "content-type")) {
	        ret = Fchg32((FBFR32 *)phpBuf, CONTENT_TYPE, 0, val, strlen(val));
		if (ret < 0) {
		    userlog("Problem setting content-type in return buffer: %s", Fstrerror32(Ferror32));
		} else {
		    userlog("Set content-type %s in return buffer", val);
		}
#if 0
	        if (ctx->content_type) {
		    efree(ctx->content_type);
		}
		ctx->content_type = estrdup(val);
#endif
	    } else if (!strcasecmp(sapi_header->header, "set-cookie")) {
	        ret = Fchg32((FBFR32 *)phpBuf, HTTP_COOKIE, 0, val, strlen(val));
		if (ret < 0) {
		    userlog("Problem setting cookie in return buffer: %s", Fstrerror32(Ferror32));
		} else {
		    userlog("Set cookie %s in return buffer", val);
		}
	    } else if (!strcasecmp(sapi_header->header, "content-length")) {
	      /*	        ap_set_content_length(ctx->r, strtol(val, (char **)NULL, 10));*/
	    } else if (op == SAPI_HEADER_REPLACE) {
	      /*	        apr_table_set(ctx->r->headers_out, sapi_header->header, val);*/
	    } else {
	      /*	        apr_table_add(ctx->r->headers_out, sapi_header->header, val);*/
	    }

	    *ptr = ':';

	    return SAPI_HEADER_ADD;

      default:
	  return 0;
  }
}

static int
my_php_send_headers(sapi_headers_struct *sapi_headers TSRMLS_DC)
{
  int rc;
  const char *sline = SG(sapi_headers).http_status_line;

  userlog("send_headers called - status line: %s", sline);
  userlog("send_headers called - response code: %d", SG(sapi_headers).http_response_code);

  if (sline != NULL) {
      rc = Fchg32((FBFR32 *)phpBuf, STATUS_LINE, 0, sline, strlen(sline));
      if (rc < 0) {
	  userlog("Problem setting status_line in return buffer: %s", Fstrerror32(Ferror32));
      }
  }

  rc = Fchg32((FBFR32 *)phpBuf, RESPONSE_CODE, 0, &SG(sapi_headers).http_response_code, 0);
  if (rc < 0) {
      userlog("Problem setting response_code in return buffer: %s", Fstrerror32(Ferror32));
  }

  return SAPI_HEADER_SENT_SUCCESSFULLY;
}

static int
my_php_read_post(char *buf, uint count_bytes TSRMLS_DC)
{
  long len;
  int rc;

  if (read_post) return 0;

  userlog("count_bytes: %d", count_bytes);

  len = count_bytes;
  rc = Fget32((FBFR32 *)inbuf, POST_DATA, 0, (char *)buf, &len);
  if (rc < 0) {
      userlog("No POST_DATA: %s", Fstrerror32(Ferror32)); 
      
      return 0;
  } else {
      userlog("Got POST_DATA: len: %d, val: %s", len, buf);
  }

  read_post = 1;

  return len - 1;
}

static void
my_php_register_variables(zval *vars_array TSRMLS_DC)
{
    if (inbuf != NULL) {
      register_variable(PATH_INFO, vars_array);
      register_variable(REQUEST_URI, vars_array);
      register_variable(QUERY_STRING, vars_array);
      register_variable(PATH_TRANSLATED, vars_array);
      register_variable(SCRIPT_FILENAME, vars_array);
      register_variable(SCRIPT_NAME, vars_array);
      register_variable(REQUEST_METHOD, vars_array);
      register_variable(HTTP_COOKIE, vars_array);
      register_variable(DOCUMENT_ROOT, vars_array);
      register_variable(SERVER_PROTOCOL, vars_array);
      register_variable(SERVER_ADMIN, vars_array);
      register_variable(GATEWAY_INTERFACE, vars_array);
      register_variable(SERVER_PORT, vars_array);
      register_variable(REMOTE_ADDR, vars_array);
      register_variable(REMOTE_PORT, vars_array);
      register_variable(HTTP_ACCEPT_LANGUAGE, vars_array);
      register_variable(HTTP_ACCEPT_CHARSET, vars_array);
      register_variable(SERVER_NAME, vars_array);
      register_variable(SERVER_ADDR, vars_array);
      register_variable(SERVER_SIGNATURE, vars_array);
      register_variable(SERVER_SOFTWARE, vars_array);
      register_variable(HTTP_ACCEPT, vars_array);
      register_variable(HTTP_ACCEPT_ENCODING, vars_array);
      register_variable(HTTP_HOST, vars_array);
      register_variable(HTTP_USER_AGENT, vars_array);
      register_variable(HTTP_CONNECTION, vars_array);
      register_variable(HTTP_CACHE_CONTROL, vars_array);
    } else {
      userlog("inbuf NULL");
    }

}

static char *
my_php_getenv(char *name, size_t name_len TSRMLS_DC)
{
  userlog("getenv name: %s", name);

  return NULL;
}

/* tpsvrinit is executed when a server is booted, before it begins
   processing requests.  It is not necessary to have this function.
   Also available is tpsvrdone (not used in this example), which is
   called at server shutdown time.
*/

#if defined(__STDC__) || defined(__cplusplus)
tpsvrinit(int argc, char *argv[])
#else
tpsvrinit(argc, argv)
int argc;
char **argv;
#endif
{
    TSRMLS_FETCH();
    /* Some compilers warn if argc and argv aren't used. */
    argc = argc;
    argv = argv;

    php_embed_module.ub_write = my_php_ub_write;
    php_embed_module.flush = my_php_ub_flush;
    php_embed_module.register_server_variables = my_php_register_variables;
    php_embed_module.read_post = my_php_read_post;
    php_embed_module.read_cookies = my_php_read_cookies;
    php_embed_module.getenv = my_php_getenv;
    php_embed_module.header_handler = my_php_header_handler;
    php_embed_module.send_headers = my_php_send_headers;

    php_embed_init(argc, argv TSRMLS_CC);

    userlog("PHP Web handler booted");
    
    return(0);
}

void tpsvrdone() 
{
  /*  php_embed_shutdown(TSRMLS_C);*/
}

/* This function performs the actual service requested by the client.
   Its argument is a structure containing among other things a pointer
   to the data buffer, and the length of the data buffer.
*/

#ifdef __cplusplus
extern "C"
#endif
void
#if defined(__STDC__) || defined(__cplusplus)
PHPWEB(TPSVCINFO *rqst)
#else
PHPWEB(rqst)
TPSVCINFO *rqst;
#endif
{
  zend_file_handle script;

  context *ctx;

  char filename[PATH_MAX];
  char request_uri[256];
  char request_method[256];
  char content_type[256];
  char document_root[PATH_MAX];
  long content_length;
  char query_string[1024];
  long len;
  char *last_slash;
  int rc;

  TSRMLS_FETCH();

  phpBuf = (char *)tpalloc("FML32", NULL, 100 * 1024);
  userlog("allocated phpBuf: %p", phpBuf);
  response = tpalloc("CARRAY", NULL, 100 * 1024);
  memset(response, '\0', 100 * 1024);
  gPos = 0;

  inbuf = rqst->data;
  read_post = 0;

#if 0
  php_embed_module.ub_write = my_php_ub_write;
  php_embed_module.flush = my_php_ub_flush;
  PHP_EMBED_START_BLOCK(1, argv)
#endif
  zend_first_try { 

    ctx = SG(server_context) = malloc(sizeof(context));

    ctx->request_processed = 0;

    /* script.type = ZEND_HANDLE_FP;*/
    len = sizeof(filename);
    Fget32((FBFR32 *)rqst->data, SCRIPT_FILENAME, 0, filename, &len);

    script.type = ZEND_HANDLE_FILENAME;
    script.filename = filename;
    userlog("loading php script: %s", filename);
    /*    script.filename = "/media/src/test_php/a.php";*/
    script.opened_path = NULL;
    script.free_filename = 0;

#if 0
    len = sizeof(request_uri);
    Fget32((FBFR32 *)rqst->data, REQUEST_URI, 0, request_uri, &len);
    SG(request_info).request_uri = strdup(request_uri);
    SG(request_info).path_translated = strdup(filename);
    SG(request_info).content_type = strdup("text/html");
    SG(request_info).query_string = strdup("");
    SG(request_info).request_method = strdup("GET");
#endif
    len = sizeof(request_uri);
    Fget32((FBFR32 *)rqst->data, REQUEST_URI, 0, request_uri, &len);
    SG(request_info).request_uri = strdup(request_uri);
    len = sizeof(request_method);
    Fget32((FBFR32 *)rqst->data, REQUEST_METHOD, 0, request_method, &len);
    SG(request_info).request_method = strdup(request_method);
    len = sizeof(content_length);
    rc = Fget32((FBFR32 *)rqst->data, CONTENT_LENGTH, 0, (char *)&content_length, &len);
    if (rc < 0) {
        userlog("Problem getting CONTENT_LENGTH: %s", Fstrerror32(Ferror32)); 
    } else {
        SG(request_info).content_length = content_length;
    }
    len = sizeof(content_type);
    rc = Fget32((FBFR32 *)rqst->data, CONTENT_TYPE, 0, content_type, &len);
    if (rc < 0) {
        userlog("Problem getting CONTENT_TYPE: %s", Fstrerror32(Ferror32)); 
    } else {
        userlog("setting content_type: %s", content_type);
        SG(request_info).content_type = strdup(content_type);
    }
    len = sizeof(query_string);
    rc = Fget32((FBFR32 *)rqst->data, QUERY_STRING, 0, query_string, &len);
    if (rc < 0) {
        userlog("Problem getting QUERY_STRING: %s", Fstrerror32(Ferror32)); 
    } else {
        userlog("setting query_string: %s", query_string);
	SG(request_info).query_string = strdup(query_string);
    }

    /*
    len = sizeof(document_root);
    Fget32((FBFR32 *)rqst->data, DOCUMENT_ROOT, 0, document_root, &len);
    */
    last_slash = strrchr(filename, '/');
    memset(document_root, '\0', sizeof(document_root));
    strncpy(document_root, filename, last_slash - filename);
    userlog("setting current directory: %s", document_root);
    chdir(document_root);

    php_request_startup(TSRMLS_C);

    php_execute_script(&script TSRMLS_CC);
    /*    zend_execute_scripts(ZEND_INCLUDE TSRMLS_CC, NULL, 1, &script);*/

    ctx->request_processed = 1;
  /*    zend_eval_string("echo 'Hello World\n';", NULL, "Embedded Code" TSRMLS_CC);*/

    php_request_shutdown(NULL);
  } zend_catch {
    /* int exit_status = EG(exit_status); */ 
  } zend_end_try();
#if 0
  PHP_EMBED_END_BLOCK()
#endif

  free(ctx);

  if (gPos > 0) {
      rc = Fchg32((FBFR32 *)phpBuf, RESPONSE_DATA, 0, response, gPos);
      if (rc < 0) {
	  userlog("Problem setting response in return buffer: %s", Fstrerror32(Ferror32));
	  tpreturn(TPFAIL, 0, NULL, 0L, 0);
      } else {
	  userlog("Set content of length %d in return buffer", gPos);
      }
  }

  tpfree(response);

  tpreturn(TPSUCCESS, 0, phpBuf, 0L, 0);
}
