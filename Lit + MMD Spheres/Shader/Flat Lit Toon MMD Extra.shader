Shader "Rhy Custom Shaders/Toon + Spheres/Basic"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_ColorMask("ColorMask", 2D) = "black" {}
		_ColorIntensity("Intensity", Range(0, 5)) = 1.0
		_SphereAddTex("Sphere Add Texture", 2D) = "black" {}
		_SphereAddIntensity("Add Sphere Texture Intensity", Range(0, 500)) = 1.0
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
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[HDR]_EmissionAltColor("Emission Alt Color", Color) = (0,0,0,1)
		_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range(0,5)) = 1
		_NormalMask("Normal Mask", 2D) = "White" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		_Opacity("Opacity", Range(1,0)) = 0
		_SpecularBleed("Specular Bleedthrough", Range(0,1)) = 0.1
		_ClampMin("Minimum Light Intensity", Range(0,3)) = 0
		_ClampMax("Maximum Light Intensity", Range(1,5)) = 5
		_EmissionToggle("Emission Toggle", Float) = 0
		//_Queue ("RenderQueue", string) = "geometry"

		// Blending state
		[HideInInspector] _Select ("__select", Int) = 0
		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _Queue ("__queue", Float) = 0.0
		[HideInInspector] _Cull ("__cull", Float) = 0.0
		[HideInInspector] _OutlineMode("__outline_mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
		[HideInInspector] _StencilRef("Stencil Reference Value", Range(0, 255)) = 2
	}

	SubShader
	{
		Tags
		{
			"Queue"= "geometry"
			"RenderType" = "Opaque"
			"IgnoreProjector"="True"
		}

		Pass
		{
			Name "FORWARD"
			Tags { 
				"LightMode" = "ForwardBase"
			}

			Blend [_SrcBlend] [_DstBlend]
			ZWrite On
			ZTest LEqual
			LOD 200
			Cull [_Cull]
						
			CGPROGRAM
			#include "FlatLitToonCoreMMD Extra.cginc"
			#include "RhyShaderHelperFunction.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#pragma only_renderers d3d11 glcore gles

			float2 emissionUV;
			float2 emissionMovement;
			float emissionMin;
			float emissionMax;

			LightContainer Lighting;
			MatcapContainer Matcap;

			float4 frag(VertexOutput i, float facing : VFACE) : COLOR 
			{
				float faceSign = ( facing >= 0 ? 1 : -1 );

				float4 white = float4(1,1,1,1);
				float4 black = float4(0,0,0,0);
				float light_Env = float(any(_WorldSpaceLightPos0.xyz));
				float4 lightColor = float4(_LightColor0.rgb, _LightColor0.w);
				float AvgIntensity = (_LightColor0.r + _LightColor0.g + _LightColor0.b)/3;

				emissionMin = 0;
				emissionMax = 2;

				emissionUV = i.uv0;
				emissionUV.x += _Time.x * _SpeedX;
				emissionUV.y += _Time.x * _SpeedY;
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));

				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				_NormalIntensity *= tex2D(_NormalMask, i.uv0);
				float3 normalDirection = CalculateNormal(TRANSFORM_TEX(i.uv0, _BumpMap), _BumpMap, tangentTransform, _NormalIntensity);

				float4 baseColor = CalculateColor(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex), _Color);			

				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);
				Lighting = CalculateLight(_WorldSpaceLightPos0, _LightColor0, normalDirection, attenuation, _ClampMin, _ClampMax);

				float4 _EmissionMap_var = tex2D(_EmissionMap,TRANSFORM_TEX(i.uv0, _EmissionMap));
				float4 emissionMask_var = tex2D(_EmissionMask,TRANSFORM_TEX(emissionUV, _EmissionMask));
				float3 emissive = _EmissionMap_var.rgb;

				if(_EmissionToggle == 1)
					emissive.rgb *= _EmissionColor;
				else
					emissive.rgb *= _EmissionAltColor;

				emissive.rgb *= emissionMask_var.rgb;
				emissive.rgb *= _EmissionIntensity;
				
				float rampValue = smoothstep(0, Lighting.bw_lightDif, 0 - dot(ShadeSH9(float4(0, 0, 0, 1)), grayscale_vector));
				float tempValue = (0.5 * dot(normalDirection, Lighting.lightDir) + 0.57);
				float3 shadowTexColor = tex2D(_ShadowTex, rampValue);
				float4 shadowMask_var = tex2D(_ShadowMask,TRANSFORM_TEX(i.uv0, _ShadowMask));

				tempValue = (tempValue + shadowMask_var.rgb);
				float3 toonTexColor = tex2D(_ToonTex, tempValue);

				Lighting.indirectLit += ((shadowTexColor + (.5 * shadowMask_var.rgb)) * Lighting.lightCol);

				Matcap = CalculateSphere(normalDirection, i, _SphereAddTex, _SphereMulTex, _SphereMap, TRANSFORM_TEX(i.uv0, _SphereMap), _SpecularBleed, faceSign, attenuation);

				if(light_Env == 1)
					Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity) * Matcap.Shadow;
				else
					Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity);

				Matcap.Mul.rgb *= _SphereMulIntensity;

				float finalAlpha = baseColor.a;

				if(_Mode == 1)
				{
					if(finalAlpha - _Cutoff < 0)
						clip (finalAlpha - _Cutoff);
					else
						finalAlpha = 1;
				}
				if (_Mode == 4)
				{
					finalAlpha = _Opacity;
					_ColorIntensity *= _Opacity;
					Matcap.Add *= _Opacity;
					Matcap.Mul *= _Opacity;
				}
				
				float3 finalColor = emissive + (Matcap.Add + (_ColorIntensity * (baseColor.rgb * toonTexColor) * Matcap.Mul)) * (lerp(Lighting.indirectLit, Lighting.directLit, attenuation));

				if(light_Env != 1)
					finalColor = emissive + (Matcap.Add + (_ColorIntensity * (baseColor.rgb * toonTexColor) * Matcap.Mul)) * Lighting.lightCol;

				fixed4 finalRGBA = fixed4(finalColor, finalAlpha);					
				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}
			ENDCG
		}			
		
		Pass
		{
			Name "FORWARD_DELTA"
			Tags 
			{ 
				"LightMode" = "ForwardAdd"
			}
			Blend [_SrcBlend] One
			ZWrite On
			ZTest LEqual
			LOD 200
			Cull [_Cull]
			Fog { Color (0,0,0,0) } // in additive pass fog should be black
			

			CGPROGRAM
			#include "FlatLitToonCoreMMD Extra.cginc"
			#include "RhyShaderHelperFunction.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#pragma only_renderers d3d11 glcore gles
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog

			LightContainer Lighting;
			MatcapContainer Matcap;
			
			float4 frag(VertexOutput i, float facing : VFACE) : COLOR
			{
				float faceSign = ( facing >= 0 ? 1 : -1 );
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				
				float4 white = float4(1,1,1,1);
				float4 black = float4(0,0,0,0);
				float light_Env = float(any(_WorldSpaceLightPos0.xyz));

				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);

				float3 normalDirection = CalculateNormal(TRANSFORM_TEX(i.uv0, _BumpMap), _BumpMap, tangentTransform, _NormalIntensity);
				normalDirection *= TRANSFORM_TEX(i.uv0, _NormalMask).r;
				float4 baseColor = CalculateColor(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex), _Color);			

				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);

				Lighting = CalculateLight(_WorldSpaceLightPos0, _LightColor0, normalDirection, attenuation, _ClampMin, _ClampMax);
				
				float rampValue = smoothstep(0, Lighting.bw_lightDif, 0 - dot(ShadeSH9(float4(0, 0, 0, 1)), grayscale_vector));
				float tempValue = (0.5 * dot(normalDirection, Lighting.lightDir) + 0.57);
				float3 shadowTexColor = tex2D(_ShadowTex, rampValue);
				float4 shadowMask_var = tex2D(_ShadowMask,TRANSFORM_TEX(i.uv0, _ShadowMask));

				tempValue = (tempValue + shadowMask_var.rgb);
				float3 toonTexColor = tex2D(_ToonTex, tempValue);
				
				Lighting.indirectLit += ((shadowTexColor + (.5 * shadowMask_var.rgb)) * Lighting.lightCol);
				
				Matcap = CalculateSphere(normalDirection, i, _SphereAddTex, _SphereMulTex, _SphereMap, TRANSFORM_TEX(i.uv0, _SphereMap), _SpecularBleed, faceSign, attenuation);

				if(light_Env == 1)
					Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity) * Matcap.Shadow;
				else
					Matcap.Add.rgb *= (Matcap.Mask * _SphereAddIntensity);

				Matcap.Mul.rgb *= _SphereMulIntensity;

				float finalAlpha = baseColor.a;

				if(_Mode == 1)
				{
					if(finalAlpha - _Cutoff < 0)
						clip (finalAlpha - _Cutoff);
					else
						finalAlpha = 1;
				}
				if (_Mode == 4)
				{
					finalAlpha = _Opacity;
					_ColorIntensity *= _Opacity;
					Matcap.Add *= _Opacity;
					Matcap.Mul *= _Opacity;
				}
				
				float3 finalColor = (Matcap.Add + (_ColorIntensity * (baseColor.rgb * toonTexColor) * Matcap.Mul)) * (lerp(0, Lighting.directLit, attenuation));

				if(light_Env != 1)
					finalColor = (Matcap.Add + (_ColorIntensity * (baseColor.rgb * toonTexColor) * Matcap.Mul)) * Lighting.lightCol;
				#if defined(DIRECTIONAL)
					finalColor = finalColor * 0.00001;
				#endif

				fixed4 finalRGBA = fixed4(finalColor, finalAlpha);					
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
			Cull [_Cull]

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
	Fallback "Toon/Lit (Double)"
	CustomEditor "RhyFlatLitMMDEditor"
}