Shader "Rhy Custom Shaders/DPS/Pen"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_ColorMask("ColorMask", 2D) = "black" {}
		_ColorIntensity("Intensity", Range(0, 5)) = 1.0
		_SphereAddTex("Sphere Add Texture", 2D) = "black" {}
		_SphereAddIntensity("Add Sphere Texture Intensity", Range(0, 500)) = 1.0
		_SphereAddSubTex("Sphere Add Sub Texture", 2D) = "black" {}
		_SphereAddSubIntensity("Add Sphere Sub Texture Intensity", Range(0, 500)) = 1.0
		_SphereMulTex("Sphere Multiply Texture", 2D) = "white" {}
		_SphereMulIntensity("Multiply Sphere Texture Intensity", Range(0, 500)) = 1.0
		_DefaultLightDir("Default Light Direction", Vector) = (1,1,1,0)
		_ToonTex("Toon Texture", 2D) = "white" {}
		_ShadowTex("Shadow Texture", 2D) = "white" {}
		_ShadowMask("Shadow Mask", 2D) = "black" {}
		_outline_width("outline_width", Float) = 0.2
		_outline_color("outline_color", Color) = (0.5,0.5,0.5,1)
		_outline_tint("outline_tint", Range(0, 1)) = 0.5
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissionMask("Emission Mask", 2D) = "white" {}
		_EmissionIntensity("Emission Intensity", Range(0, 20)) = 0.0
		_SpeedX("Emission X speed", Float) = 1.0
		_SpeedY("Emission Y speed", Float) = 1.0
		_SphereMap("Sphere Mask", 2D) = "white" {}
		_SphereSubMap("Sphere Sub Mask", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[HDR]_EmissionAltColor("Emission Alt Color", Color) = (0,0,0,1)
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		_Opacity("Opacity", Range(1,0)) = 0
		_SpecularBleed("Specular Bleedthrough", Range(0,1)) = 0.1
		_ClampMin("Minimum Light Intensity", Range(0,3)) = 0
		_ClampMax("Maximum Light Intensity", Range(1,5)) = 5
		_EmissionToggle("Emission Toggle", Float) = 0

		_OrificeData("OrificeData", 2D) = "white" {}
		_EntryOpenDuration("Entry Trigger Duration", Range( 0 , 1)) = 0.1
		_Shape1Depth("Shape 1 Trigger Depth", Range( 0 , 5)) = 0.1
		_Shape1Duration("Shape 1 Trigger Duration", Range( 0 , 1)) = 0.1
		_Shape2Depth("Shape 2 Trigger Depth", Range( 0 , 5)) = 0.2
		_Shape2Duration("Shape 2 Trigger Duration", Range( 0 , 1)) = 0.1
		_Shape3Depth("Shape 3 Trigger Depth", Range( 0 , 5)) = 0.3
		_Shape3Duration("Shape 3 Trigger Duration", Range( 0 , 1)) = 0.1
		_BlendshapePower("Blend Shape Power", Range(0,5)) = 1
		[Header(Advanced)]_OrificeChannel("OrificeChannel Please Use 0", Float) = 0
		[Header(Toon Shading (Check to activate))]_CellShadingSharpness("Cell Shading Sharpness", Range( 0 , 1)) = 0
		_ToonSpecularSize("ToonSpecularSize", Range( 0 , 1)) = 0
		_ToonSpecularIntensity("ToonSpecularIntensity", Range( 0 , 1)) = 0
		[Toggle(_TOONSHADING_ON)] _ToonShading("Toon Shading", Float) = 0

		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _Cull ("__cull", Float) = 0.0
		[HideInInspector] _OutlineMode("__outline_mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "DPSBlacklights.cginc"
		#include "PenCore.cginc"
		#include "PenHelperFunction.cginc"
		#pragma target 3.0
		#pragma multi_compile __ _TOONSHADING_ON
		#pragma surface surf StandardCustomLighting keepalpha noshadow vertex:vertexDataFunc 

		struct appdata_full_custom
		{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
			float4 texcoord3 : TEXCOORD3;
			fixed4 color : COLOR;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			uint vertexId : SV_VertexID;
		};

		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _OrificeChannel;
		uniform sampler2D _OrificeData;
		uniform float _EntryOpenDuration;
		uniform float _Shape1Depth;
		uniform float _Shape1Duration;
		uniform float _Shape2Depth;
		uniform float _Shape2Duration;
		uniform float _Shape3Depth;
		uniform float _Shape3Duration;
		uniform float _BlendshapePower;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float _EmissionPower;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;
		uniform float _Smoothness;
		uniform sampler2D _Occlusion;
		uniform float4 _Occlusion_ST;
		uniform float _CellShadingSharpness;
		uniform float _ToonSpecularSize;
		uniform float _ToonSpecularIntensity;

		uniform float2 emissionUV;
		uniform float2 emissionMovement;
		uniform float3 tangent;
		uniform float3 bitangent;
		uniform float3 t1;
		uniform float3 t2;
		LightContainer Lighting;
		MatcapContainer Matcap;

		float3 getBlendOffset(float blendSampleIndex, float activationDepth, float activationSmooth, int vertexID, float penetrationDepth, float3 normal, float3 tangent, float3 binormal) 
		{
			float blendTextureSize = 1024;
			float2 blendSampleUV = (float2(( ( fmod( (float)vertexID , blendTextureSize ) + 0.5 ) / (blendTextureSize) ) , ( ( ( floor( ( vertexID / (blendTextureSize) ) ) + 0.5 ) / (blendTextureSize) ) + blendSampleIndex/8 )));
			float3 sampledBlend = tex2Dlod( _OrificeData, float4( blendSampleUV, 0, 0.0) ).rgb;
			float blendActivation = smoothstep( ( activationDepth ) , ( activationDepth + activationSmooth ) , penetrationDepth);
			blendActivation = -cos(blendActivation*3.1416)*0.5+0.5;
			float3 blendOffset = ( ( sampledBlend - float3(1,1,1)) * (blendActivation) * _BlendshapePower );
			return ( ( blendOffset.x * normal ) + ( blendOffset.y * tangent ) + ( blendOffset.z * binormal ) );
		}

		void vertexDataFunc( inout appdata_full_custom v, out Input o )	
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float penetratorLength = 0.1;
			float penetratorDistance;
			float3 orificePositionTracker = float3(0,0,-100);
			float3 orificeNormalTracker = float3(0,0,-99);
			float3 penetratorPositionTracker = float3(0,0,100);
			float orificeType=0;
			
			GetBestLights(_OrificeChannel, orificeType, orificePositionTracker, orificeNormalTracker, penetratorPositionTracker, penetratorLength);
			penetratorDistance = distance(orificePositionTracker, penetratorPositionTracker );

			float penetrationDepth = (penetratorLength - penetratorDistance);

			float3 normal = normalize( v.normal );
			float3 tangent = normalize( v.tangent.xyz );
			float3 binormal = normalize(cross( normal , tangent ));

			v.vertex.xyz += getBlendOffset(0, 0, _EntryOpenDuration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.vertex.xyz += getBlendOffset(2, _Shape1Depth, _Shape1Duration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.vertex.xyz += getBlendOffset(4, _Shape2Depth, _Shape2Duration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.vertex.xyz += getBlendOffset(6, _Shape3Depth, _Shape3Duration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.vertex.w = 1;

			v.normal += getBlendOffset(1, 0, _EntryOpenDuration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.normal += getBlendOffset(3, _Shape1Depth, _Shape1Duration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.normal += getBlendOffset(5, _Shape2Depth, _Shape2Duration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.normal += getBlendOffset(7, _Shape3Depth, _Shape3Duration, v.vertexId, penetrationDepth, normal, tangent, binormal);
			v.normal = normalize(v.normal);

		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;

			float4 white = float4(1,1,1,1);
			float4 black = float4(0,0,0,0);
			float light_Env = float(any(_WorldSpaceLightPos0.xyz));
			float4 lightColor = (_LightColor0.rgb, 1);

			emissionUV = i.uv_texcoord;
			emissionUV.x += _Time.x * _SpeedX;
			emissionUV.y += _Time.x * _SpeedY;
			float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));

			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			s.Normal = UnpackNormal(tex2D(_BumpMap, i.uv_texcoord));
			float3 normalDirection = WorldNormalVector(i, s.Normal);

			//s.Normal = normalize(s.Normal);
			//tangent = cross(s.Normal, float3(1,1,1));
			//bitangent = cross(s.Normal, tangent) * tangent.x;
			//float3x3 tangentTransform = float3x3(tangent, bitangent, s.Normal);
			//float3 normalDirection = CalculateNormal(TRANSFORM_TEX(i.uv_texcoord, _BumpMap), _BumpMap, tangentTransform);
			float4 baseColor = CalculateColor(_MainTex, TRANSFORM_TEX(i.uv_texcoord, _MainTex), _Color);			

			UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
			//attenuation = FadeShadows(attenuation, i.posWorld.xyz);

			Lighting = CalculateLight(_WorldSpaceLightPos0, _LightColor0, normalDirection, attenuation, _ClampMin, _ClampMax);

			float4 _EmissionMap_var = tex2D(_EmissionMap,TRANSFORM_TEX(i.uv_texcoord, _EmissionMap));
			float4 emissionMask_var = tex2D(_EmissionMask,TRANSFORM_TEX(emissionUV, _EmissionMask));
			float3 emissive = _EmissionMap_var.rgb;

			if(_EmissionToggle == 1)
				emissive.rgb *= _EmissionColor;
			else
				emissive.rgb *= _EmissionAltColor;

			emissive.rgb *= emissionMask_var.rgb;
			emissive.rgb *= _EmissionIntensity;
				
			float rampValue = smoothstep(0, Lighting.bw_lightDif, 0 - dot(ShadeSH9(float4(0, 0, 0, 1)), grayscale_vector));
			float tempValue = (0.5 * dot(normalDirection, Lighting.lightDir) + 0.5);
			float3 toonTexColor = tex2D(_ToonTex, tempValue);
			float3 shadowTexColor = tex2D(_ShadowTex, rampValue);
			float4 shadowMask_var = tex2D(_ShadowMask, TRANSFORM_TEX(i.uv_texcoord, _ShadowMask));
				
			Lighting.indirectLit += (shadowTexColor * Lighting.lightCol);

			Matcap = CalculateSphere(normalDirection, i.worldPos, _SphereAddTex, _SphereMulTex, _SphereMap, TRANSFORM_TEX(i.uv_texcoord, _SphereMap), _SpecularBleed, 1, attenuation);

			if(light_Env == 1)
				Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity) * Matcap.Shadow;
			else
				Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity);

			Matcap.Mul.rgb *= _SphereMulIntensity;

			float3 sphereSubMap_var = tex2D(_SphereSubMap, TRANSFORM_TEX(i.uv_texcoord, _SphereSubMap));
			float4 sphereSubAdd = tex2D(_SphereAddSubTex, Matcap.UV);

			if(light_Env == 1)
				sphereSubAdd.rgb *= (sphereSubMap_var * _SphereAddSubIntensity) * Matcap.Shadow;
			else
				sphereSubAdd.rgb *= (sphereSubMap_var * _SphereAddSubIntensity);

			float finalAlpha = baseColor.a;

			if(_Mode == 1)
			{
				if(finalAlpha - _Cutoff < 0)
					clip (finalAlpha - _Cutoff);
				else
					finalAlpha = 1;
			}
			if(_Mode == 3)
				finalAlpha = _Opacity;


				
			float3 finalColor = emissive + ((Matcap.Add + sphereSubAdd) + ((_ColorIntensity / 2) * (baseColor.rgb * toonTexColor) * Matcap.Mul)) * (lerp(Lighting.indirectLit, Lighting.directLit, attenuation));

			c.rgb = finalColor;
			c.a = finalAlpha;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode145 = tex2D( _MainTex, uv_MainTex );
			float4 temp_output_146_0 = ( tex2DNode145 * _Color );
			o.Albedo = temp_output_146_0.rgb;
		}

		ENDCG
	}
	CustomEditor "RhyOriEditor"
}
