/*
===========================================================================

Doom 3 GPL Source Code
Copyright (C) 1999-2011 id Software LLC, a ZeniMax Media company.

This file is part of the Doom 3 GPL Source Code ("Doom 3 Source Code").

Doom 3 Source Code is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Doom 3 Source Code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Doom 3 Source Code.  If not, see <http://www.gnu.org/licenses/>.

In addition, the Doom 3 Source Code is also subject to certain additional terms. You should have received a copy of these additional terms immediately following the terms and conditions of the GNU General Public License which accompanied the Doom 3 Source Code.  If not, please request a copy in writing from id Software at the address below.

If you have questions concerning this license or the applicable additional terms, you may contact in writing id Software LLC, c/o ZeniMax Media Inc., Suite 120, Rockville, Maryland 20850 USA.

===========================================================================
*/
/*
** QGL.H
*/

#ifndef __QGL_H__
#define __QGL_H__

#if defined( ID_DEDICATED ) && defined( _WIN32 )
// to allow stubbing gl on windows, define WINGDIAPI to nothing - it would otherwise be
// extended to __declspec(dllimport) on MSVC (our stub is no dll.)
	#ifdef WINGDIAPI
		#pragma push_macro("WINGDIAPI")
		#undef WINGDIAPI
		#define WINGDIAPI
	#endif
#endif

#include <SDL_opengl.h>

#if defined( ID_DEDICATED ) && defined( _WIN32 )
// restore WINGDIAPI
	#ifdef WINGDIAPI
		#pragma pop_macro("WINGDIAPI")
	#endif
#endif

typedef void (*GLExtension_t)(void);

#ifdef __cplusplus
	extern "C" {
#endif

GLExtension_t GLimp_ExtensionPointer( const char *name );

#ifdef __cplusplus
	}
#endif

// declare qgl functions
#define QGLPROC(name, rettype, args) extern rettype (APIENTRYP q##name) args;
#include "renderer/qgl_proc.h"

// multitexture
extern	void ( APIENTRY * qglMultiTexCoord2fARB )( GLenum texture, GLfloat s, GLfloat t );
extern	void ( APIENTRY * qglMultiTexCoord2fvARB )( GLenum texture, GLfloat *st );
extern	void ( APIENTRY * qglActiveTexture )( GLenum texture );
extern	void ( APIENTRY * qglClientActiveTextureARB )( GLenum texture );

// ARB_vertex_buffer_object
extern PFNGLBINDBUFFERPROC qglBindBuffer;
extern PFNGLDELETEBUFFERSPROC qglDeleteBuffers;
extern PFNGLGENBUFFERSPROC qglGenBuffers;
extern PFNGLISBUFFERPROC qglIsBuffer;
extern PFNGLBUFFERDATAPROC qglBufferData;
extern PFNGLBUFFERSUBDATAPROC qglBufferSubData;
extern PFNGLGETBUFFERSUBDATAPROC qglGetBufferSubData;
extern PFNGLMAPBUFFERPROC qglMapBuffer;
extern PFNGLUNMAPBUFFERPROC qglUnmapBuffer;
extern PFNGLGETBUFFERPARAMETERIVPROC qglGetBufferParameteriv;
extern PFNGLGETBUFFERPOINTERVPROC qglGetBufferPointerv;

// 3D textures
extern void ( APIENTRY *qglTexImage3D)(GLenum, GLint, GLint, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid *);

// shared texture palette
extern	void ( APIENTRY *qglColorTableEXT)( int, int, int, int, int, const void * );

// EXT_stencil_two_side
extern	PFNGLACTIVESTENCILFACEEXTPROC	qglActiveStencilFaceEXT;

// ARB_texture_compression
extern	PFNGLCOMPRESSEDTEXIMAGE2DARBPROC	qglCompressedTexImage2D;
extern	PFNGLGETCOMPRESSEDTEXIMAGEARBPROC	qglGetCompressedTexImage;

// ARB_vertex_program / ARB_fragment_program
extern PFNGLVERTEXATTRIBPOINTERPROC		qglVertexAttribPointer;
extern PFNGLENABLEVERTEXATTRIBARRAYPROC	qglEnableVertexAttribArray;
extern PFNGLDISABLEVERTEXATTRIBARRAYPROC	qglDisableVertexAttribArray;
extern PFNGLPROGRAMSTRINGARBPROC			qglProgramStringARB;
extern PFNGLBINDPROGRAMARBPROC				qglBindProgramARB;
extern PFNGLGENPROGRAMSARBPROC				qglGenProgramsARB;
extern PFNGLPROGRAMENVPARAMETER4FVARBPROC	qglProgramEnvParameter4fvARB;
extern PFNGLPROGRAMLOCALPARAMETER4FVARBPROC	qglProgramLocalParameter4fvARB;

// GL_EXT_depth_bounds_test
extern PFNGLDEPTHBOUNDSEXTPROC				qglDepthBoundsEXT;

//GLSL - use only for tess shaders, therefore be depend of this
extern PFNGLCREATEPROGRAMPROC				qglCreateProgram;
extern PFNGLCREATESHADERPROC				qglCreateShader;
extern PFNGLSHADERSOURCEPROC				qglShaderSource;
extern PFNGLCOMPILESHADERPROC				qglCompileShader;
extern PFNGLGETSHADERIVPROC					qglGetShaderiv;
extern PFNGLGETSHADERINFOLOGPROC			qglGetShaderInfoLog;
extern PFNGLATTACHSHADERPROC				qglAttachShader;
extern PFNGLUSEPROGRAMPROC					qglUseProgram;
extern PFNGLLINKPROGRAMPROC					qglLinkProgram;
extern PFNGLDELETEPROGRAMPROC				qglDeleteProgram;
extern PFNGLDELETESHADERPROC				qglDeleteShader;

// Tesselation
extern PFNGLPATCHPARAMETERIPROC				qglPatchParameteri;
extern PFNGLPATCHPARAMETERFVPROC			qglPatchParameterfv;
extern PFNGLUNIFORMMATRIX4FVPROC			qglUniformMatrix4fv;

#endif
