#ifndef FLAT_LIT_TOON_SHADOWS_INCLUDED

#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"

// Do dithering for alpha blended shadows on SM3+/desktop;
// on lesser systems do simple alpha-tested shadows
// Need to output UVs in shadow caster, since we need to sample texture and do clip/dithering based on it

uniform float4      _Color;
uniform float       _Cutoff;
uniform sampler2D   _MainTex;
uniform sampler2D   _ShadowMask;
uniform float4      _MainTex_ST;
uniform float4      _ShadowMask_ST;
uniform float		_Mode;

struct VertexInput
{
    float4 vertex   : POSITION;
    float3 normal   : NORMAL;
    float2 uv0      : TEXCOORD0;
};


// Don't make the structure if it's empty (it's an error to have empty structs on some platforms...)
struct VertexOutputShadowCaster
{
    V2F_SHADOW_CASTER_NOPOS
    // Need to output UVs in shadow caster, since we need to sample texture and do clip/dithering based on it
    float2 tex : TEXCOORD0;
};

// We have to do these dances of outputting SV_POSITION separately from the vertex shader,
// and inputting VPOS in the pixel shader, since they both map to "POSITION" semantic on
// some platforms, and then things don't go well.


void vertShadowCaster(VertexInput v,
    out VertexOutputShadowCaster o,
    out float4 opos : SV_POSITION)
{
    TRANSFER_SHADOW_CASTER_NOPOS(o, opos)
    o.tex = v.uv0;
}

half4 fragShadowCaster
(
    VertexOutputShadowCaster i
        , UNITY_VPOS_TYPE vpos : VPOS
	
	
) : SV_Target
{
	half alpha = tex2D(_MainTex, TRANSFORM_TEX(i.tex, _MainTex)).a;
	half shadowMask = tex2D(_ShadowMask, TRANSFORM_TEX(i.tex, _ShadowMask)).r;

	if(_Mode == 1)
		if(alpha < _Cutoff)
			clip(-1);

	if(_Mode == 2)
		if(alpha < 1)
			clip(-1);

	if(shadowMask < 1)
		SHADOW_CASTER_FRAGMENT(i)
	else
		//clip(-1);
		return _Color;
}

#endif