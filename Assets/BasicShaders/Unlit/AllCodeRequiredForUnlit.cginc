﻿// This is like a header file in c, called cginc (C for graphics include)
// And its going to contain all required functions and structs
// For our basic shaders
// It is really good practice to keep all the shaders stuff in cginc file

// These pre-processor macros required to avoid duplicated including
// https://gcc.gnu.org/onlinedocs/gcc-3.0.2/cpp_2.html (Check 2.4 Once-Only Headers)
#ifndef ALL_CODE_REQUIRED_FOR_UNLIT
#define ALL_CODE_REQUIRED_FOR_UNLIT

// You might already know that shader don't have include files
// This is unity created thing
// So what it does copies the source code to our shader
#include "UnityCG.cginc" // Include basic unity functions and built in values veriables
#include "Lighting.cginc" // Includes some lighting veriables

// Data generated by unity CPU side and passed to vertex function
struct VertData
{
	float4 pos : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
};

// Data generated by geometry function and combined with render target
struct FragData
{
	float4 pos : SV_POSITION; /* SV_POSITION specifies that this is our pixel position */
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
};

//Vertex function/shader
FragData vertBasic(VertData i)
{
	FragData o;

	// UNITY_MATRIX_MVP this is per instance matrix, that describes transformation
	// object space => world space => camera space => screen space
	o.pos = mul(UNITY_MATRIX_MVP, i.pos); 

	// Function UnityObjectToWorldNormal transforms from object space into worldspace only rotation
	// because you can't move or sqale normal vector
	o.normal = UnityObjectToWorldNormal(i.normal);

	o.uv = i.uv;
	return o;
}

// Sampler + texture this is how it actually looks:
// struct sampler2D { Texture2D t; SamplerState s; };
// So when call function like tex2D (Its macro), its translated into
// float4 tex2D(sampler2D x, float2 v)				{ return x.t.Sample(x.s, v); }
sampler2D _MainTex;

fixed4 _Color;

// Fragment function/shader.
// Also know as pixel shader, it might sound more correct name, because its output pixel color.
// However because of MSAA (Multisample anti-aliasing), fragment function could be called multiple times per same pixel.
// So its more correct to call it fragment and not pixel.
fixed4 fragBasic(FragData i) : SV_TARGET /* SV_TARGET/COLOR is our lord semantic that says return value will be our output color*/
{
	fixed4 finalColor = fixed4(0, 0, 0, 0);

	// Sampling process.
	// So texture will be sampled depending on options you gave in unity texture importer.
	// https://en.wikipedia.org/wiki/Texture_filtering
	fixed4 diffuseColor = tex2D(_MainTex, i.uv);

	finalColor += diffuseColor * _Color;

	return finalColor;
}

fixed4 fragBasicVarations(FragData i) : SV_TARGET
{
	fixed4 finalColor = fixed4(0, 0, 0, 0);

	// Sampling process.
	// So texture will be sampled depending on options you gave in unity texture importer.
	// https://en.wikipedia.org/wiki/Texture_filtering
	fixed4 diffuseColor = tex2D(_MainTex, i.uv);

	finalColor += diffuseColor * _Color;

	#ifdef _COLORTYPE_INVERTEDCOLOR
		return 1 - finalColor;
	#else
		return finalColor;
	#endif
}

#endif // ALL_CODE_REQUIRED_FOR_UNLIT