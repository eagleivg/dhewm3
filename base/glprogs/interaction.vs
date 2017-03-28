/*
===========================================================================

Doom 3 BFG Edition GPL Source Code
Copyright (C) 1993-2012 id Software LLC, a ZeniMax Media company. 

This file is part of the Doom 3 BFG Edition GPL Source Code ("Doom 3 BFG Edition Source Code").  

Doom 3 BFG Edition Source Code is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Doom 3 BFG Edition Source Code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Doom 3 BFG Edition Source Code.  If not, see <http://www.gnu.org/licenses/>.

In addition, the Doom 3 BFG Edition Source Code is also subject to certain additional terms. You should have received a copy of these additional terms immediately following the terms and conditions of the GNU General Public License which accompanied the Doom 3 BFG Edition Source Code.  If not, please request a copy in writing from id Software at the address below.

If you have questions concerning this license or the applicable additional terms, you may contact in writing id Software LLC, c/o ZeniMax Media Inc., Suite 120, Rockville, Maryland 20850 USA.

===========================================================================
*/
uniform vec4 rpScreenCorrectionFactor	;
uniform vec4 rpWindowCoord			;
uniform vec4 rpDiffuseModifier		;
uniform vec4 rpSpecularModifier		;

uniform vec4 rpLocalLightOrigin		;
uniform vec4 rpLocalViewOrigin		;

uniform vec4 rpLightProjectionS		;
uniform vec4 rpLightProjectionT		;
uniform vec4 rpLightProjectionQ		;
uniform vec4 rpLightFalloffS		;

uniform vec4 rpBumpMatrixS			;
uniform vec4 rpBumpMatrixT			;

uniform vec4 rpDiffuseMatrixS		;
uniform vec4 rpDiffuseMatrixT		;

uniform vec4 rpSpecularMatrixS		;
uniform vec4 rpSpecularMatrixT		;

uniform vec4 rpVertexColorModulate	;
uniform vec4 rpVertexColorAdd		;

uniform vec4 rpColor				;
uniform vec4 rpViewOrigin			;
uniform vec4 rpGlobalEyePos			;

uniform vec4 rpMVPmatrixX			;
uniform vec4 rpMVPmatrixY			;
uniform vec4 rpMVPmatrixZ			;
uniform vec4 rpMVPmatrixW			;

uniform vec4 rpModelMatrixX			;
uniform vec4 rpModelMatrixY			;
uniform vec4 rpModelMatrixZ			;
uniform vec4 rpModelMatrixW			;

uniform vec4 rpProjectionMatrixX	;
uniform vec4 rpProjectionMatrixY	;
uniform vec4 rpProjectionMatrixZ	;
uniform vec4 rpProjectionMatrixW	;

uniform vec4 rpModelViewMatrixX		;
uniform vec4 rpModelViewMatrixY		;
uniform vec4 rpModelViewMatrixZ		;
uniform vec4 rpModelViewMatrixW		;

uniform vec4 rpTextureMatrixS		;
uniform vec4 rpTextureMatrixT		;

uniform vec4 rpTexGen0S				;
uniform vec4 rpTexGen0T				;
uniform vec4 rpTexGen0Q				;
uniform vec4 rpTexGen0Enabled		;

uniform vec4 rpTexGen1S				;
uniform vec4 rpTexGen1T				;
uniform vec4 rpTexGen1Q				;
uniform vec4 rpTexGen1Enabled		;

uniform vec4 rpWobbleSkyX			;
uniform vec4 rpWobbleSkyY			;
uniform vec4 rpWobbleSkyZ			;

uniform vec4 rpOverbright			;
uniform vec4 rpEnableSkinning		;
uniform vec4 rpAlphaTest			;

static float dot2( vec2 a, vec2 b ) { return dot( a, b ); }
static float dot3( vec3 a, vec3 b ) { return dot( a, b ); }
static float dot3( vec3 a, vec4 b ) { return dot( a, b.xyz ); }
static float dot3( vec4 a, vec3 b ) { return dot( a.xyz, b ); }
static float dot3( vec4 a, vec4 b ) { return dot( a.xyz, b.xyz ); }
static float dot4( vec4 a, vec4 b ) { return dot( a, b ); }
static float dot4( vec2 a, vec4 b ) { return dot( vec4( a, 0, 1 ), b ); }

// ----------------------
// YCoCg Color Conversion
// ----------------------
static const half4 matrixRGB1toCoCg1YX = half4(  0.50,  0.0, -0.50, 0.50196078 );	// Co
static const half4 matrixRGB1toCoCg1YY = half4( -0.25,  0.5, -0.25, 0.50196078 );	// Cg
static const half4 matrixRGB1toCoCg1YZ = half4(  0.0,   0.0,  0.0,  1.0 );			// 1.0
static const half4 matrixRGB1toCoCg1YW = half4(  0.25,  0.5,  0.25, 0.0 );			// Y

static const half4 matrixCoCg1YtoRGB1X = half4(  1.0, -1.0,  0.0,        1.0 );
static const half4 matrixCoCg1YtoRGB1Y = half4(  0.0,  1.0, -0.50196078, 1.0 ); // -0.5 * 256.0 / 255.0
static const half4 matrixCoCg1YtoRGB1Z = half4( -1.0, -1.0,  1.00392156, 1.0 ); // +1.0 * 256.0 / 255.0

static half3 ConvertYCoCgToRGB( half4 YCoCg ) {
	half3 rgbColor;

	YCoCg.z = ( YCoCg.z * 31.875 ) + 1.0;			//z = z * 255.0/8.0 + 1.0
	YCoCg.z = 1.0 / YCoCg.z;
	YCoCg.xy *= YCoCg.z;
	rgbColor.x = dot4( YCoCg, matrixCoCg1YtoRGB1X );
	rgbColor.y = dot4( YCoCg, matrixCoCg1YtoRGB1Y );
	rgbColor.z = dot4( YCoCg, matrixCoCg1YtoRGB1Z );
	return rgbColor;
}

static vec2 CenterScale( vec2 inTC, vec2 centerScale ) {
	float scaleX = centerScale.x;
	float scaleY = centerScale.y;
	vec4 tc0 = vec4( scaleX, 0, 0, 0.5 - ( 0.5f * scaleX ) );
	vec4 tc1 = vec4( 0, scaleY, 0, 0.5 - ( 0.5f * scaleY ) );

	vec2 finalTC;
	finalTC.x = dot4( inTC, tc0 );
	finalTC.y = dot4( inTC, tc1 );
	return finalTC;
}

static vec2 Rotate2D( vec2 inTC, vec2 cs ) {
	float sinValue = cs.y;
	float cosValue = cs.x;

	vec4 tc0 = vec4( cosValue, -sinValue, 0, ( -0.5f * cosValue ) + ( 0.5f * sinValue ) + 0.5f );
	vec4 tc1 = vec4( sinValue, cosValue, 0, ( -0.5f * sinValue ) + ( -0.5f * cosValue ) + 0.5f );

	vec2 finalTC;
	finalTC.x = dot4( inTC, tc0 );
	finalTC.y = dot4( inTC, tc1 );
	return finalTC;
}

// better noise function available at https://github.com/ashima/webgl-noise
float rand( vec2 co ) {
    return frac( sin( dot( co.xy, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 );
}


#define _half2( x )		half2( x )
#define _half3( x )		half3( x )
#define _half4( x )		half4( x )
#define _vec2( x )	vec2( x )
#define _vec3( x )	vec3( x )
#define _vec4( x )	vec4( x )

#define VPOS WPOS
static vec4 idtex2Dproj( sampler2D samp, vec4 texCoords ) { return tex2Dproj( samp, texCoords.xyw ); }
static vec4 swizzleColor( vec4 c ) { return c; }
static vec2 vposToScreenPosTexCoord( vec2 vpos ) { return vpos.xy * rpWindowCoord.xy; }


#define BRANCH
#define IFANY

struct VS_IN {
	vec3 position 	: POSITION;
	vec2 texcoord 	: TEXCOORD0;
	vec3 normal 		: NORMAL;
	vec3 tangent 		: TANGENT;
	vec3 bitangent 	: BITANGENT;
	vec4 color 		: COLOR0;
};

struct VS_OUT {
	vec4 position		: POSITION;
	vec4 texcoord0	: TEXCOORD0;
	vec4 texcoord1	: TEXCOORD1;
	vec4 texcoord2	: TEXCOORD2;
	vec4 texcoord3	: TEXCOORD3;
	vec4 texcoord4	: TEXCOORD4;
	vec4 texcoord5	: TEXCOORD5;
	vec4 texcoord6	: TEXCOORD6;
	vec4 color		: COLOR0;
};

void main( VS_IN vertex, out VS_OUT result ) {

	vec3x3 tangentToWorld = vec3x3( vertex.tangent, vertex.bitangent, vertex.normal );
	vec4x4 mvpMatrix = vec4x4( rpMVPmatrixX, rpMVPmatrixY, rpMVPmatrixZ, rpMVPmatrixW );

	vec4 vertexPos = vec4( vertex.position, 1.0f );
	result.position = mvpMatrix * vertexPos;

	vec4 defaultTexCoord = vec4( 0.0f, 0.5f, 0.0f, 1.0f );

	//calculate vector to light in R0
	vec4 toLight = rpLocalLightOrigin - vertexPos;

	//result.texcoord0
	result.texcoord0.xyz = toLight.xyz * tangentToWorld;

	//textures 1 takes the base coordinates by the texture matrix
	result.texcoord1 = defaultTexCoord;
	result.texcoord1.x = dot4( vertex.texcoord.xy, rpBumpMatrixS );
	result.texcoord1.y = dot4( vertex.texcoord.xy, rpBumpMatrixT );

	//# texture 2 has one texgen
	result.texcoord2 = defaultTexCoord;
	result.texcoord2.x = dot4( vertexPos, rpLightFalloffS );

	//# texture 3 has three texgens
	result.texcoord3.x = dot4( vertexPos, rpLightProjectionS );
	result.texcoord3.y = dot4( vertexPos, rpLightProjectionT );
	result.texcoord3.z = 0.0f;
	result.texcoord3.w = dot4( vertexPos, rpLightProjectionQ );

	//# textures 4 takes the base coordinates by the texture matrix
	result.texcoord4 = defaultTexCoord;
	result.texcoord4.x = dot4( vertex.texcoord.xy, rpDiffuseMatrixS );
	result.texcoord4.y = dot4( vertex.texcoord.xy, rpDiffuseMatrixT );

	//# textures 5 takes the base coordinates by the texture matrix
	result.texcoord5 = defaultTexCoord;
	result.texcoord5.x = dot4( vertex.texcoord.xy, rpSpecularMatrixS );
	result.texcoord5.y = dot4( vertex.texcoord.xy, rpSpecularMatrixT );

	//# texture 6's texcoords will be the halfangle in texture space

	//# calculate normalized vector to light in R0
	toLight = normalize( toLight );

	//# calculate normalized vector to viewer in R1
	vec4 toView = normalize( rpLocalViewOrigin - vertexPos );
	
	//# add together to become the half angle vector in object space (non-normalized)
	vec4 halfAngleVector = toLight + toView;

	//# put into texture space
	result.texcoord6.xyz = halfAngleVector.xyz * tangentToWorld;
	result.texcoord6.w = 1.0f;

	//# generate the vertex color, which can be 1.0, color, or 1.0 - color
	//# for 1.0 : env[16] = 0, env[17] = 1
	//# for color : env[16] = 1, env[17] = 0
	//# for 1.0-color : env[16] = -1, env[17] = 1	
	result.color = ( swizzleColor( vertex.color ) * rpVertexColorModulate ) + rpVertexColorAdd;
}
