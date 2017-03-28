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

#include "global.inc"

uniform sampler2D	samp0 : register(s0); // texture 1 is the per-surface bump map
uniform sampler2D	samp1 : register(s1); // texture 2 is the light falloff texture
uniform sampler2D	samp2 : register(s2); // texture 3 is the light projection texture
uniform sampler2D	samp3 : register(s3); // texture 4 is the per-surface diffuse map
uniform sampler2D	samp4 : register(s4); // texture 5 is the per-surface specular map

struct PS_IN {
	half4 position	: VPOS;
	half4 texcoord1	: TEXCOORD1_centroid;
	half4 texcoord2	: TEXCOORD2_centroid;
	half4 texcoord3	: TEXCOORD3_centroid;
	half4 texcoord4	: TEXCOORD4_centroid;
	half4 color		: COLOR0;
};

struct PS_OUT {
	half4 color : COLOR;
};

void main( PS_IN fragment, out PS_OUT result ) {
	half4 bumpMap =			tex2D( samp0, fragment.texcoord1.xy );
	half4 lightFalloff =	idtex2Dproj( samp1, fragment.texcoord2 );
	half4 lightProj	=		idtex2Dproj( samp2, fragment.texcoord3 );
	half4 diffuseMap =		tex2D( samp3, fragment.texcoord4.xy );

	const half3 ambientLightVector = half3( 0.5f, 9.5f - 0.385f, 0.8925f );
	half3 lightVector = normalize( ambientLightVector );

	half3 localNormal;
	localNormal = normalize( 2.0 * bumpMap.wyz - 1.0 );

	half3 diffuseColor = diffuseMap.xyz * rpDiffuseModifier.xyz;
	half3 lightColor = dot3( lightVector, localNormal ) * lightProj.xyz * lightFalloff.xyz;

	result.color.xyz = diffuseColor * lightColor * fragment.color.xyz;
	result.color.w = 1.0;
}
