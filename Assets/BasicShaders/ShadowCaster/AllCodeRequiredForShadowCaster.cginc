﻿// This is like a header file in c, called cginc (C for graphics include)
// And its going to contain all required functions and structs
// For our basic shaders
// It is really good practice to keep all the shaders stuff in cginc file

// These pre-processor macros required to avoid duplicated including
// https://gcc.gnu.org/onlinedocs/gcc-3.0.2/cpp_2.html (Check 2.4 Once-Only Headers)
#ifndef ALL_CODE_REQUIRED_FOR_SHADOW_CASTER
#define ALL_CODE_REQUIRED_FOR_SHADOW_CASTER

// You might already know that shader don't have include files
// This is unity created thing
// So what it does copies the source code to our shader
#include "UnityCG.cginc" // Include basic unity functions and built in values veriables
#include "Lighting.cginc" // Includes some lighting veriables

// Data generated by unity CPU side and passed to vertex function
struct VertData
{
	float4 vertex : POSITION; // vertex naming required by TRANSFER_SHADOW_CASTER. 
	float2 uv : TEXCOORD0;
};

// Data generated by geometry function and combined with render target of define.
struct FragData
{
	/*
	// Declare all data needed for shadow caster pass output (any shadow directions/depths/distances as needed),
	// plus clip space position.
	#define V2F_SHADOW_CASTER V2F_SHADOW_CASTER_NOPOS float4 pos : SV_POSITION
	*/
	V2F_SHADOW_CASTER;
	float2 uv : TEXCOORD0;
};

//Vertex function/shader
FragData vertShadowCaster(VertData v /* v naming required by TRANSFER_SHADOW_CASTER */)
{
	FragData o;
	o.uv = v.uv;
	// Full code can be found in "UnityCG.cginc".
	TRANSFER_SHADOW_CASTER(o)
	return o;
}

// Sampler + texture this is how it actually looks:
// struct sampler2D { Texture2D t; SamplerState s; };
// So when call function like tex2D (Its macro), its translated into
// float4 tex2D(sampler2D x, float2 v)				{ return x.t.Sample(x.s, v); }
sampler2D _MainTex;

// Fragment function/shader.
// Also know as pixel shader, it might sound more correct name, because its output pixel color.
// However because of MSAA (Multisample anti-aliasing), fragment function could be called multiple times per same pixel.
// So its more correct to call it fragment and not pixel.
fixed4 fragShadowCaster(FragData i) : SV_TARGET /* SV_TARGET/COLOR is our lord semantic that says return value will be our output color*/
{
	// Sampling process.
	// So texture will be sampled depending on options you gave in unity texture importer.
	// https://en.wikipedia.org/wiki/Texture_filtering
	// We only use it in shadows caster, for shadow cliping.
	fixed4 diffuseColor = tex2D(_MainTex, i.uv);

	// So this call is pretty simple if argument is negative we discard all the pixel operations.
	// In this case if we have alpha = 0, we don't draw shadow.
	// https://www.google.lt/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=hlsl+clip
	clip(diffuseColor.a - 0.01);

	// Full code can be found in "UnityCG.cginc".
	// Thea reason why it is in define, because shadow can be casted from multiple light sources
	// point light/ spot light/ directional light.

	// From "UnityCG.cginc".
	/*#ifdef SHADOWS_CUBE
		// Rendering into point light (cubemap) shadows
		#define V2F_SHADOW_CASTER_NOPOS float3 vec : TEXCOORD0;
		#define TRANSFER_SHADOW_CASTER_NOPOS_LEGACY(o,opos) o.vec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz; opos = UnityObjectToClipPos(v.vertex);
		#define TRANSFER_SHADOW_CASTER_NOPOS(o,opos) o.vec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz; opos = UnityObjectToClipPos(v.vertex);
		#define SHADOW_CASTER_FRAGMENT(i) return UnityEncodeCubeShadowDepth ((length(i.vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
	#else
		// Rendering into directional or spot light shadows
		#define V2F_SHADOW_CASTER_NOPOS
		// Let embedding code know that V2F_SHADOW_CASTER_NOPOS is empty; so that it can workaround
		// empty structs that could possibly be produced.
		#define V2F_SHADOW_CASTER_NOPOS_IS_EMPTY
		#define TRANSFER_SHADOW_CASTER_NOPOS_LEGACY(o,opos) \
			opos = UnityObjectToClipPos(v.vertex.xyz); \
			opos = UnityApplyLinearShadowBias(opos);
		#define TRANSFER_SHADOW_CASTER_NOPOS(o,opos) \
			opos = UnityClipSpaceShadowCasterPos(v.vertex.xyz, v.normal); \
			opos = UnityApplyLinearShadowBias(opos);
		#define SHADOW_CASTER_FRAGMENT(i) return 0;
	#endif*/

	SHADOW_CASTER_FRAGMENT(i)
}

#endif // ALL_CODE_REQUIRED_FOR_SHADOW_CASTER