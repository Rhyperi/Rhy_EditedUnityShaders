#ifndef FLAT_LIT_TOON_CORE_INCLUDED

#include "UnityStandardBRDF.cginc"
#include "UnityPBSLighting.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#pragma multi_compile_fog
#pragma only_renderers d3d9 d3d11 glcore gles 
#pragma target 3.0
//#pragma addshadow
		
uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
uniform sampler2D _ColorMask; uniform float4 _ColorMask_ST;
uniform sampler2D _SphereAddTex; uniform float4 _SphereAddTex_ST;
uniform sampler2D _SphereAddSubTex; uniform float4 _SphereAddSubTex_ST;
uniform sampler2D _SphereMap; uniform float4 _SphereMap_ST;
uniform sampler2D _SphereSubMap; uniform float4 _SphereSubMap_ST;
uniform sampler2D _MultiMap; uniform float4 _MultiMap_ST;
uniform sampler2D _SphereMulTex; uniform float4 _SphereMulTex_ST;
uniform sampler2D _ToonTex; uniform float4 _ToonTex_ST;
uniform sampler2D _ShadowTex; uniform float4 _ShadowTex_ST;
uniform sampler2D _ShadowMask; uniform float4 _ShadowMask_ST;
uniform sampler2D _HighlightTex; uniform float4 _HighlightTex_ST;
uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
uniform sampler2D _EmissionMask; uniform float4 _EmissionMask_ST;
uniform sampler2D _EmissionMap2; uniform float4 _EmissionMap2_ST;
uniform sampler2D _EmissionMask2; uniform float4 _EmissionMask2_ST;
uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
uniform sampler2D _DetailMap; uniform float4 _DetailMap_ST;
uniform sampler2D _NormalMask; uniform float4 _NormalMask_ST;
uniform sampler2D inTexture; uniform float4 inTexture_ST;
uniform sampler2D inNormal; uniform float4 inNormal_ST;

uniform float _SpeedX; uniform float _SpeedY;
uniform float _SpeedX2; uniform float _SpeedY2;
uniform float4 _Color; uniform float4 _rTint; uniform float4 _bTint; uniform float4 _gTint; 
uniform float _ColorIntensity;
uniform float _SphereAddIntensity;
uniform float _SphereAddSubIntensity;
uniform float _SphereMulIntensity;
uniform float _Cutoff;
uniform float4 _EmissionColor;
uniform float _EmissionIntensity;
uniform float4 _EmissionColor2;
uniform float _EmissionIntensity2;
uniform float4 _EmissionAltColor;
uniform float4 _EmissionAltColor2;
uniform float _outline_width;
uniform float4 _outline_color;
uniform float4 _DefaultLightDir;
uniform float _SpecularToggle;
uniform float _Mode;
uniform float _Opacity;
uniform float _SpecularBleed;
uniform float _Fader;
uniform float _ClampMin, _ClampMax;
uniform float _EmissionToggle, _EmissionToggle2;


static const float3 grayscale_vector = float3(0, 0.3823529, 0.01845836);

struct v2g
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float4 posWorld : TEXCOORD2;
	float3 normalDir : TEXCOORD3;
	float3 tangentDir : TEXCOORD4;
	float3 bitangentDir : TEXCOORD5;
	float4 pos : CLIP_POS;
	SHADOW_COORDS(6)
	UNITY_FOG_COORDS(7)
};

v2g vert(appdata_full v) {
	v2g o;
	o.uv0 = v.texcoord;
	o.uv1 = v.texcoord1;
	o.normal = v.normal;
	o.tangent = v.tangent;
	o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
	o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
	o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
	float4 objPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
	o.posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.vertex = v.vertex;
	o.pos = UnityObjectToClipPos(v.vertex);
	TRANSFER_SHADOW(o);
	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}

struct VertexOutput
{
	float4 pos : SV_POSITION;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float4 posWorld : TEXCOORD2;
	float3 normalDir : TEXCOORD3;
	float3 tangentDir : TEXCOORD4;
	float3 bitangentDir : TEXCOORD5;
	float4 col : COLOR;
	SHADOW_COORDS(6)
	UNITY_FOG_COORDS(7)
};

[maxvertexcount(6)]
void geom(triangle v2g IN[3], inout TriangleStream<VertexOutput> tristream)
{
	VertexOutput o;
	for (int ii = 0; ii < 3; ii++)
	{
		o.pos = UnityObjectToClipPos(IN[ii].vertex);
		o.uv0 = IN[ii].uv0;
		o.uv1 = IN[ii].uv1;
		o.col = fixed4(1., 1., 1., 0.);
		o.posWorld = mul(unity_ObjectToWorld, IN[ii].vertex);
		o.normalDir = UnityObjectToWorldNormal(IN[ii].normal);
		o.tangentDir = IN[ii].tangentDir;
		o.bitangentDir = IN[ii].bitangentDir;
		o.posWorld = mul(unity_ObjectToWorld, IN[ii].vertex);

		// Pass-through the shadow coordinates if this pass has shadows.
		#if defined (SHADOWS_SCREEN) || ( defined (SHADOWS_DEPTH) && defined (SPOT) ) || defined (SHADOWS_CUBE)
		o._ShadowCoord = IN[ii]._ShadowCoord;
		#endif

		// Pass-through the fog coordinates if this pass has shadows.
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
		o.fogCoord = IN[ii].fogCoord;
		#endif

		tristream.Append(o);
	}

	tristream.RestartStrip();
}
#endif