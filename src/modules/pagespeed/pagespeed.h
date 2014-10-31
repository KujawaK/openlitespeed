/*****************************************************************************
*    Open LiteSpeed is an open source HTTP server.                           *
*    Copyright (C) 2014  LiteSpeed Technologies, Inc.                        *
*                                                                            *
*    This program is free software: you can redistribute it and/or modify    *
*    it under the terms of the GNU General Public License as published by    *
*    the Free Software Foundation, either version 3 of the License, or       *
*    (at your option) any later version.                                     *
*                                                                            *
*    This program is distributed in the hope that it will be useful,         *
*    but WITHOUT ANY WARRANTY; without even the implied warranty of          *
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            *
*    GNU General Public License for more details.                            *
*                                                                            *
*    You should have received a copy of the GNU General Public License       *
*    along with this program. If not, see http://www.gnu.org/licenses/.      *
*****************************************************************************/
#ifndef LSI_PAGESPEEND_H_
#define LSI_PAGESPEEND_H_

#include "../include/ls.h"
#include "ls_rewrite_driver_factory.h"
#include "psol/include/out/Release/obj/gen/net/instaweb/public/version.h"
#include "base/logging.h"
#include "net/instaweb/http/public/response_headers.h"
#include "net/instaweb/util/public/string_util.h"


#define     MNAME           modpagespeed
#define     ModuleName      "modpagespeed"
const char kModuleName[] =  "Module::modpagespeed";

#define PAGESPEED_MODULEKEY     ModuleName
#define PAGESPEED_MODULEKEYLEN  (sizeof(ModuleName) -1)

//#define AprTimer   PosixTimer

extern lsi_module_t MNAME;

using namespace net_instaweb;

namespace net_instaweb
{
    class GzipInflater;
    class StringAsyncFetch;
    class ProxyFetch;
    class RewriteDriver;
    class RequestHeaders;
    class ResponseHeaders;
    class InPlaceResourceRecorder;

// s1: AutoStr, s2: string literal
// true if they're equal, false otherwise
#define STR_EQ_LITERAL(s1, s2)          \
    ((s1).len() == (sizeof(s2)-1) &&      \
     strncmp((s1).c_str(), (s2), (sizeof(s2)-1)) == 0)

// s1: ngx_str_t, s2: string literal
// true if they're equal ignoring case, false otherwise
#define STR_CASE_EQ_LITERAL(s1, s2)     \
    ((s1).len() == (sizeof(s2)-1) &&      \
     strncasecmp((s1).c_str(), (s2), (sizeof(s2)-1)) == 0)


    enum PreserveCachingHeaders
    {
        kPreserveAllCachingHeaders,  // Cache-Control, ETag, Last-Modified, etc
        kPreserveOnlyCacheControl,   // Only Cache-Control.
        kDontPreserveHeaders,
    };

    void copy_response_headers_from_server( lsi_session_t* session,
                                            ResponseHeaders* headers );

    void copy_request_headers_from_server( lsi_session_t* session,
                                           RequestHeaders* headers );

    int copy_response_headers_to_server( lsi_session_t* session,
                                         const ResponseHeaders& pagespeed_headers,
                                         PreserveCachingHeaders preserve_caching_headers );

    int copy_response_body_to_buff( lsi_session_t* session, const char* s, int len, int done_called );

    StringPiece ps_determine_host( lsi_session_t* session );

    int ps_determine_port( lsi_session_t* session );

}  // namespace net_instaweb


namespace RequestRouting
{
    enum Response
    {
        kError,
        kNotUnderstood,
        kStaticContent,
        kInvalidUrl,
        kPagespeedDisabled,
        kBeacon,
        kStatistics,
        kGlobalStatistics,
        kConsole,
        kMessages,
        kAdmin,
        kCachePurge,
        kGlobalAdmin,
        kPagespeedSubrequest,
        kNotHeadOrGet,
        kErrorResponse,
        kResource,
    };
}  // namespace RequestRouting

#endif //LSI_PAGESPEEND_H_

