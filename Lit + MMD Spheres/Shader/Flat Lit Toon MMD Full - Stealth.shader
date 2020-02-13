Shader "Rhy Custom Shaders/Flat Lit Toon + MMD/Stealth"
{
	Properties
	{
		_Stealth ("Stealth", Range(0, 1)) = 0.7378641
        _StealthScale ("StealthScale", Float ) = 2
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_ColorMask("ColorMask", 2D) = "black" {}
		_ColorIntensity("Intensity", Range(0, 5)) = 1.0
		_SphereAddTex("Sphere Add Texture", 2D) = "black" {}
		_SphereAddIntensity("Add Sphere Texture Intensity", Range(0, 5)) = 1.0
		_SphereMulTex("Sphere Multiply Texture", 2D) = "white" {}
		_SphereMulIntensity("Multiply Sphere Texture Intensity", Range(0, 5)) = 1.0
		_DefaultLightDir("Default Light Direction", Vector) = (1,1,1,0)
		_ToonTex("Toon Texture", 2D) = "white" {}
		_ShadowTex("Shadow Texture", 2D) = "white" {}
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_EmissiveIntensity ("EmissiveIntensity", Float ) = 1
		_EmissionMask("Emission Mask", 2D) = "white" {}
		_SpeedX("Emission X speed", Float) = 1.0
		_SpeedY("Emission Y speed", Float) = 1.0
		_SphereMap("Sphere Mask", 2D) = "white" {}
		_BumpMap("BumpMap", 2D) = "bump" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		_NormalIntensity ("Normal Intensity", Range(0, 10)) = 1
        _Pattern ("Pattern", 2D) = "white" {}
		_PatternColor ("Pattern Color", Color) = (1,1,1,1)
        _PatternSpeed ("PatternSpeed", Float ) = 0.1
        _PatternScale ("PatternScale", Float ) = 1
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		_Opacity("Opacity", Range(1,0)) = 0
		_SpecularBleed("Specular Bleedthrough", Range(0,1)) = 0.1
        [MaterialToggle] _StartTopBottom ("StartTop/Bottom", Float ) = 1
        [MaterialToggle] _VisibleEffect ("VisibleEffect", Float ) = 0
        _VisibleEffectIntensity ("VisibleEffectIntensity", Float ) = 1
        _MinVisibility ("Min Visibility", Range(0, 1)) = 0
        _RefractionIntensity ("RefractionIntensity", Float ) = 1
        [MaterialToggle] _TriplanarUV2 ("Triplanar/UV2", Float ) = 0
        [MaterialToggle] _PatternTriplanarUV1 ("PatternTriplanar/UV1", Float ) = 0
		[MaterialToggle] _RefractionAndPattern ("Toggle Pattern and Refraction", Float) = 1
		[HideInInspector]_outline_width("outline_width", Float) = 0.2
		[HideInInspector]_outline_color("outline_color", Color) = (0.5,0.5,0.5,1)
		[HideInInspector]_outline_tint("outline_tint", Range(0, 1)) = 0.5

		// Blending state
		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _Cull ("__cull", Float) = 0.0
		[HideInInspector] _OutlineMode("__outline_mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
	}

	SubShader
	{
		Tags
		{
            "Queue" = "Transparent-1"
            "RenderType" = "Transparent"
		}

		GrabPass{ "Refraction" }
		Pass
		{

			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

			Blend [_SrcBlend] [_DstBlend]
			ZWrite On
			ZTest LEqual
			LOD 200
			Cull [_Cull]

			CGPROGRAM
			#include "FlatLitToonCore MMD + Stealth.cginc"
			#include "RhyShaderHelperFunction.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			uniform sampler2D Refraction; uniform float4 Refraction_ST;
            uniform float4 _TimeEditor;
            uniform float _RoughnessIntensity;
            uniform float _Stealth;
            uniform float _StealthScale;
            uniform sampler2D _Pattern; uniform float4 _Pattern_ST;
            uniform fixed _StartTopBottom;
            uniform float _PatternSpeed;
            uniform float4 _PatternColor;
            uniform float _EmissiveIntensity;
            uniform sampler2D _Emissive; uniform float4 _Emissive_ST;
            uniform float _PatternScale;
            uniform fixed _VisibleEffect;
            uniform float _VisibleEffectIntensity;
            uniform float _MinVisibility;
            uniform float _RefractionIntensity;
            uniform float4 _EmissiveColor;
            uniform float _NormalIntensity;
            uniform fixed _TriplanarUV2;
            uniform fixed _PatternTriplanarUV1;
            uniform float _PBREmissiveIntensity;
			uniform float _RefractionAndPattern;
			
			uniform float2 emissionUV;
			uniform float2 emissionMovement;
			LightContainer Lighting;
			MatcapContainer Matcap;
			
			float4 frag(VertexOutput i, float facing : VFACE) : COLOR
			{
				float faceSign = ( facing >= 0 ? 1 : -1 );
				emissionUV = i.uv0;
				emissionUV.x += _Time.x * _SpeedX;
				emissionUV.y += _Time.x * _SpeedY;
			
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				i.normalDir = normalize(i.normalDir);
				i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
				
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 normalDirection = CalculateNormal(TRANSFORM_TEX(i.uv0, _BumpMap), _BumpMap, tangentTransform);
				float4 baseColor = CalculateColor(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex), _Color);		
				
				float node_7877 = baseColor.a;
                float4 node_3326 = _Time + _TimeEditor;
                float node_6088 = (node_3326.g*_PatternSpeed);
                float node_3784 = (0.1*_PatternScale);
                float2 node_6494 = ((i.uv0*node_3784)+node_6088*float2(1,0));
                float4 _node_6231 = tex2D(_Pattern,TRANSFORM_TEX(node_6494, _Pattern));
                float3 node_9231 = abs(i.normalDir);
                float3 node_7265 = (node_9231*node_9231);
                float3 node_157 = (i.posWorld.rgb-objPos.rgb).rgb;
                float2 node_3852 = ((float2(node_157.g,node_157.b)*node_3784)+node_6088*float2(1,0));
                float4 node_2867 = tex2D(_Pattern,TRANSFORM_TEX(node_3852, _Pattern));
                float2 node_1326 = ((float2(node_157.b,node_157.r)*node_3784)+node_6088*float2(1,0));
                float4 node_2137 = tex2D(_Pattern,TRANSFORM_TEX(node_1326, _Pattern));
                float2 node_6826 = ((float2(node_157.r,node_157.g)*node_3784)+node_6088*float2(1,0));
                float4 node_2297 = tex2D(_Pattern,TRANSFORM_TEX(node_6826, _Pattern));
                float node_9984 = lerp( _node_6231.r, saturate((node_7265.r*node_2867.r + node_7265.g*node_2137.r + node_7265.b*node_2297.r)), _PatternTriplanarUV1 );
                float node_9778 = clamp(node_9984,0,1);
                float node_9302 = (lerp( i.uv1.g, normalize((i.posWorld.rgb-objPos.rgb)).rgb.g, _TriplanarUV2 )*lerp( 1.0, (-1.0), _StartTopBottom ));
                float node_3485 = (1.0 - ((_Stealth*3.0+-1.5)*_StealthScale));
                float2 sceneUVs = i.screenPos.xy*0.5+0.5 + (_RefractionAndPattern * ((node_7877*0.5)*saturate((clamp(((node_9778*(0.1*_RefractionIntensity))*saturate((node_9302+(node_3485+2.0)))),0,1)+saturate((node_9984*(_MinVisibility*0.1))))).rr));
                float4 sceneColor = tex2D(Refraction, UnityStereoTransformScreenSpaceTex(sceneUVs));
				
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);
				attenuation = FadeShadows(attenuation, i.posWorld.xyz);

				Lighting = CalculateLight(_WorldSpaceLightPos0, _LightColor0, normalDirection, attenuation);
				
				float node_1333 = (1.0 - ((10.0*node_9302)+node_9778+(((node_9984*0.1)+node_3485)*10.0+-5.0)));
                float node_1162 = (node_3485+node_9778+node_9302);
                float node_2121 = saturate(node_1162);
                float node_8264 = (lerp( 0.0, (pow(1.0-max(0,dot(normalDirection, viewDirection)),5.0)*3.0*(1.0 - node_2121)), _VisibleEffect )*_VisibleEffectIntensity);
            
				float4 _EmissionMap_var = tex2D(_EmissionMap,TRANSFORM_TEX(i.uv0, _EmissionMap));
				float4 emissionMask_var = tex2D(_EmissionMask,TRANSFORM_TEX(emissionUV, _EmissionMask));
				float3 emissive = ((saturate((_PatternColor.rgb*saturate((1.0 - (node_1333*(node_1333-(0.0+(10.0*node_1162))))))))*_EmissiveIntensity)+(_PatternColor.rgb*node_8264));
				emissive.rgb *= emissionMask_var.rgb;
				
				float3 baseEmissive = (_EmissionMap_var.rgb * _EmissionColor.rgb);					
				baseEmissive.rgb *= emissionMask_var.rgb;
				baseEmissive.rgb *= _EmissiveIntensity;
				
				float rampValue = smoothstep(0, Lighting.bw_lightDif, 0 - dot(ShadeSH9(float4(0, 0, 0, 1)), grayscale_vector));
				float tempValue = (0.5 * dot(normalDirection, Lighting.lightDir) + 0.5);
				float3 toonTexColor = tex2D(_ToonTex, tempValue);
				float3 shadowTexColor = tex2D(_ShadowTex, rampValue);

				Lighting.indirectLit += (shadowTexColor * Lighting.lightCol);
				Matcap = CalculateSphere(normalDirection, i, _SphereAddTex, _SphereMulTex, _SphereMap, TRANSFORM_TEX(i.uv0, _SphereMap), _SpecularBleed, faceSign, attenuation);

				Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity) * Matcap.Shadow;
				Matcap.Mul.rgb *= _SphereMulIntensity;

				float finalAlpha = baseColor.a;

				if(_Mode == 1)
					clip (finalAlpha - _Cutoff);
				if(_Mode == 3)
					finalAlpha -= _Opacity;

				float3 finalColor = (baseEmissive + emissive) + ((_ColorIntensity / 2) * baseColor.rgb * toonTexColor * (Matcap.Mul + Matcap.Add)) * (lerp(Lighting.indirectLit, Lighting.directLit, attenuation));

				fixed4 finalRGBA = fixed4(lerp(sceneColor.rgb, finalColor,(node_7877*saturate(((node_2121*1.0)+node_8264)))), finalAlpha)
				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}
			ENDCG
		}

		Pass
		{
			Name "FORWARD_DELTA"
			Tags { "LightMode" = "ForwardAdd" }
			Blend [_SrcBlend] One
			ZWrite On
			ZTest LEqual
			LOD 200
			Cull [_Cull]
			Fog { Color (0,0,0,0) } // in additive pass fog should be black

			CGPROGRAM
			#include "FlatLitToonCore MMD + Stealth.cginc"
			#include "RhyShaderHelperFunction.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#define UNITY_PASS_FORWARDBASE
            #define _GLOSSYENV 1
			#include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x n3ds wiiu 
            #pragma target 4.0

			uniform sampler2D Refraction; uniform float4 Refraction_ST;
            uniform float4 _TimeEditor;
            uniform float _RoughnessIntensity;
            uniform float _Stealth;
            uniform float _StealthScale;
            uniform sampler2D _Pattern; uniform float4 _Pattern_ST;
            uniform fixed _StartTopBottom;
            uniform float _PatternSpeed;
            uniform float4 _PatternColor;
            uniform float _EmissiveIntensity;
            uniform sampler2D _Emissive; uniform float4 _Emissive_ST;
            uniform float _PatternScale;
            uniform fixed _VisibleEffect;
            uniform float _VisibleEffectIntensity;
            uniform float _MinVisibility;
            uniform float _RefractionIntensity;
            uniform float4 _EmissiveColor;
            uniform float _NormalIntensity;
            uniform fixed _TriplanarUV2;
            uniform fixed _PatternTriplanarUV1;
            uniform float _PBREmissiveIntensity;
			uniform float _RefractionAndPattern;
			
			float2 emissionUV;
			float2 emissionMovement;
			LightContainer Lighting;
			MatcapContainer Matcap;
			
			float4 frag(VertexOutput i, float facing : VFACE) : COLOR
			{
				float faceSign = ( facing >= 0 ? 1 : -1 );
				emissionUV = i.uv0;
				emissionUV.x += _Time.x * _SpeedX;
				emissionUV.y += _Time.x * _SpeedY;
			
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				i.normalDir = normalize(i.normalDir);
				i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
				
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 normalDirection = CalculateNormal(TRANSFORM_TEX(i.uv0, _BumpMap), _BumpMap, tangentTransform);
				float4 baseColor = CalculateColor(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex), _Color);		
				
				float node_7877 = baseColor.a;
                float4 node_3326 = _Time + _TimeEditor;
                float node_6088 = (node_3326.g*_PatternSpeed);
                float node_3784 = (0.1*_PatternScale);
                float2 node_6494 = ((i.uv0*node_3784)+node_6088*float2(1,0));
                float4 _node_6231 = tex2D(_Pattern,TRANSFORM_TEX(node_6494, _Pattern));
                float3 node_9231 = abs(i.normalDir);
                float3 node_7265 = (node_9231*node_9231);
                float3 node_157 = (i.posWorld.rgb-objPos.rgb).rgb;
                float2 node_3852 = ((float2(node_157.g,node_157.b)*node_3784)+node_6088*float2(1,0));
                float4 node_2867 = tex2D(_Pattern,TRANSFORM_TEX(node_3852, _Pattern));
                float2 node_1326 = ((float2(node_157.b,node_157.r)*node_3784)+node_6088*float2(1,0));
                float4 node_2137 = tex2D(_Pattern,TRANSFORM_TEX(node_1326, _Pattern));
                float2 node_6826 = ((float2(node_157.r,node_157.g)*node_3784)+node_6088*float2(1,0));
                float4 node_2297 = tex2D(_Pattern,TRANSFORM_TEX(node_6826, _Pattern));
                float node_9984 = lerp( _node_6231.r, saturate((node_7265.r*node_2867.r + node_7265.g*node_2137.r + node_7265.b*node_2297.r)), _PatternTriplanarUV1 );
                float node_9778 = clamp(node_9984,0,1);
                float node_9302 = (lerp( i.uv1.g, normalize((i.posWorld.rgb-objPos.rgb)).rgb.g, _TriplanarUV2 )*lerp( 1.0, (-1.0), _StartTopBottom ));
                float node_3485 = (1.0 - ((_Stealth*3.0+-1.5)*_StealthScale));
                float2 sceneUVs = i.screenPos.xy*0.5+0.5 + (_RefractionAndPattern * ((node_7877*0.5)*saturate((clamp(((node_9778*(0.1*_RefractionIntensity))*saturate((node_9302+(node_3485+2.0)))),0,1)+saturate((node_9984*(_MinVisibility*0.1))))).rr));
                float4 sceneColor = tex2D(Refraction, UnityStereoTransformScreenSpaceTex(sceneUVs));
				
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);
				attenuation = FadeShadows(attenuation, i.posWorld.xyz);

				Lighting = CalculateLight(_WorldSpaceLightPos0, _LightColor0, normalDirection, attenuation);
				
				float node_1333 = (1.0 - ((10.0*node_9302)+node_9778+(((node_9984*0.1)+node_3485)*10.0+-5.0)));
                float node_1162 = (node_3485+node_9778+node_9302);
                float node_2121 = saturate(node_1162);
                float node_8264 = (lerp( 0.0, (pow(1.0-max(0,dot(normalDirection, viewDirection)),5.0)*3.0*(1.0 - node_2121)), _VisibleEffect )*_VisibleEffectIntensity);

				float rampValue = smoothstep(0, Lighting.bw_lightDif, 0 - dot(ShadeSH9(float4(0, 0, 0, 1)), grayscale_vector));
				float tempValue = (0.5 * dot(normalDirection, Lighting.lightDir) + 0.5);
				float3 toonTexColor = tex2D(_ToonTex, tempValue);
				float3 shadowTexColor = tex2D(_ShadowTex, rampValue);

				Lighting.indirectLit += (shadowTexColor * Lighting.lightCol);
				Matcap = CalculateSphere(normalDirection, i, _SphereAddTex, _SphereMulTex, _SphereMap, TRANSFORM_TEX(i.uv0, _SphereMap), _SpecularBleed, faceSign, attenuation);

				Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity) * Matcap.Shadow;
				Matcap.Mul.rgb *= _SphereMulIntensity;

				float finalAlpha = baseColor.a;

				if(_Mode == 1)
					clip (finalAlpha - _Cutoff);
				if(_Mode == 3)
					finalAlpha -= _Opacity;

				float3 finalColor = (((_ColorIntensity / 2) * baseColor.rgb * toonTexColor * (Matcap.Mul + Matcap.Add))) * (lerp(Lighting.indirectLit, Lighting.directLit, attenuation));

				fixed4 finalRGBA = fixed4(lerp(sceneColor.rgb, finalColor,(node_7877*saturate(((node_2121*1.0)+node_8264)))), finalAlpha)
				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}
			ENDCG
		}

		Pass
		{
			Name "SHADOW_CASTER"
			Tags{ "LightMode" = "ShadowCaster" }
			Blend [_SrcBlend] [_DstBlend]

			ZWrite On
			ZTest LEqual
			Cull Off

			CGPROGRAM
			#include "FlatLitToonShadows.cginc"
			
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma only_renderers d3d11 glcore gles
			#pragma target 4.0

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			
			ENDCG
		}
	}
	Fallback "Unlit/Texture"
	CustomEditor "RhyFlatLitMMDEditorStealth"
}