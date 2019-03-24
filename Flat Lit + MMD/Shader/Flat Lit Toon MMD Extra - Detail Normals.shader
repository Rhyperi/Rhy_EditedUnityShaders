Shader "Rhy Custom Shaders/Flat Lit Toon + MMD/Detail Normals"
{
		Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_ColorMask("ColorMask", 2D) = "black" {}
		_ColorIntensity("Intensity", Range(0, 5)) = 1.0
		_SphereAddTex("Sphere Add Texture", 2D) = "black" {}
		_SphereAddIntensity("Add Sphere Texture Intensity", Range(0, 5)) = 1.0
		_SphereMulTex("Sphere Multiply Texture", 2D) = "white" {}
		_SphereMulIntensity("Multiply Sphere Texture Intensity", Range(0, 5)) = 1.0
		_DefaultLightDir("Default Light Direction", Vector) = (1,1,1,2)
		_ToonTex("Toon Texture", 2D) = "white" {}
		_outline_width("outline_width", Float) = 0.2
		_outline_color("outline_color", Color) = (0.5,0.5,0.5,1)
		_outline_tint("outline_tint", Range(0, 1)) = 0.5
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissionMask("Emission Mask", 2D) = "white" {}
		_EmissionIntensity("Emission Intensity", Range(0, 20)) = 1.0
		_SpeedX("Emission X speed", Float) = 1.0
		_SpeedY("Emission Y speed", Float) = 1.0
		_SphereMap("Sphere Mask", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_BumpMap("Normal Map", 2D) = "bump" {}
		_DetailMap("Detail Normal Map", 2D) = "bump" {}
		_DetailMapMask("Detail Normal Map Mask", 2D) = "white" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		_SpecularToggle("Specular Toggle", Float) = 1

		// Blending state
		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _OutlineMode("__outline_mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
	}
	
	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType" = "Opaque"
		}

		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite On
			LOD 200
			Cull Off
						
			CGPROGRAM
			#include "FlatLitToonCoreMMD Extra.cginc"

			#pragma shader_feature NO_OUTLINE TINTED_OUTLINE COLORED_OUTLINE
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma target 4.0
			#pragma only_renderers d3d11 glcore gles
			
			float2 emissionUV;
			float2 emissionMovement;
			
			uniform sampler2D _DetailMap;
			float4 _DetailMap_ST;
			uniform sampler2D _DetailMapMask;
			float4 _DetailMapMask_ST;
			
			float4 frag(VertexOutput i, float facing : VFACE) : COLOR 
			{			
				float faceSign = ( facing >= 0 ? 1 : -1 );
			
				emissionUV = i.uv0;
				emissionUV.x += _Time.x * _SpeedX;
				emissionUV.y += _Time.x * _SpeedY;
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 _BumpMap_var = UnpackNormal(tex2D(_BumpMap, TRANSFORM_TEX((i.uv0 * _BumpMap_ST.xy + _BumpMap_ST.zw), _BumpMap)));
				float3 rampNormals = normalize(mul(_BumpMap_var.rgb, tangentTransform)); // Perturbed normals
				float3 _DetailMap_var = UnpackNormal(tex2D(_DetailMap, TRANSFORM_TEX((i.uv0 * _DetailMap_ST.xy + _DetailMap_ST.zw), _DetailMap)));
				float3 _DetailMapMask_var = tex2D(_DetailMapMask ,TRANSFORM_TEX(i.uv0, _DetailMapMask));
				_DetailMap_var *= _DetailMapMask_var.rgb;
				float3 normalDirection = normalize(mul((float3(_BumpMap_var.xy*_DetailMap_var.z + _DetailMap_var.xy*_BumpMap_var.z, _BumpMap_var.z*_DetailMap_var.z)), tangentTransform));
				
				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
							
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float light_Env = float(any(_WorldSpaceLightPos0.xyz));
				if( light_Env != 1)
				{
						lightDirection = normalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
					
						if(length(unity_SHAr.xyz*unity_SHAr.w + unity_SHAg.xyz*unity_SHAg.w + unity_SHAb.xyz*unity_SHAb.w) == 0)
						{
							lightDirection = normalize(_DefaultLightDir.xyz);
						}
				}
				
				float NdL = dot(normalDirection, float4(lightDirection.xyz, 0));
				
				float3 lightColor = _LightColor0.rgb;
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);

				float4 _EmissionMap_var = tex2D(_EmissionMap,TRANSFORM_TEX(i.uv0, _EmissionMap));
				float4 emissionMask_var = tex2D(_EmissionMask,TRANSFORM_TEX(emissionUV, _EmissionMask));
				float3 emissive = (_EmissionMap_var.rgb*_EmissionColor.rgb);
				emissive.rgb *= emissionMask_var.rgb;
				emissive.rgb *= _EmissionIntensity;
				
				float4 _ColorMask_var = tex2D(_ColorMask,TRANSFORM_TEX(i.uv0, _ColorMask));
				float4 baseColor = lerp((_MainTex_var.rgba*_Color.rgba),_MainTex_var.rgba,_ColorMask_var.r);

				// MMD Spheres
				float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_V, normalDirection));
				
				// position of shaded pixel in view space 0.0 to 1.0 X and Y
                float3 viewDir = normalize(UnityWorldToViewPos(i.posWorld));

				if(_SpecularToggle)
				{
					// vector perpendicular to both pixel normal and view vector
					float3 viewCross = cross(viewDir, viewNormal);
					viewNormal = float3(-viewCross.y, viewCross.x, 0.0);
					
					float cameraRoll = -atan2(UNITY_MATRIX_I_V[1].x, UNITY_MATRIX_I_V[1].y);
					float sinX = sin(cameraRoll);
					float cosX = cos(cameraRoll);
					float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
					viewNormal.xy = mul(viewNormal, rotationMatrix*faceSign);
				}
				
				float2 sphereUV = viewNormal.xy * 0.5 + 0.5;
				float4 sphereMap_var = tex2D(_SphereMap,TRANSFORM_TEX(i.uv0, _SphereMap));
				float4 sphereAdd = tex2D(_SphereAddTex, sphereUV);
				sphereAdd.rgb *= (sphereMap_var.rgb * _SphereAddIntensity );
				float4 sphereMul = tex2D(_SphereMulTex, sphereUV);
				sphereMul.rgb *= _SphereMulIntensity;

				float3 reflectionMap = DecodeHDR(UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normalize((_WorldSpaceCameraPos - objPos.rgb)), 7), unity_SpecCube0_HDR)* 0.02;

				float grayscalelightcolor = dot(_LightColor0.rgb, grayscale_vector);
				float bottomIndirectLighting = grayscaleSH9(float3(0.0, -1.0, 0.0));
				float topIndirectLighting = grayscaleSH9(float3(0.0, 1.0, 0.0));
				float grayscaleDirectLighting = dot(lightDirection, normalDirection)*grayscalelightcolor*attenuation + grayscaleSH9(normalDirection);

				float lightDifference = topIndirectLighting + grayscalelightcolor - bottomIndirectLighting;
				float remappedLight = (grayscaleDirectLighting - bottomIndirectLighting) / lightDifference;

				float3 indirectLighting = saturate((ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)) + reflectionMap));
				float3 directLighting = saturate((ShadeSH9(half4(0.0, 1.0, 0.0, 1.0)) + reflectionMap + _LightColor0.rgb));
				float3 directContribution = saturate(1 + floor(saturate(remappedLight) * 2.5));
				float remappedRamp = (NdL * 0.5 + 0.5);
				float3 toonTexColor = tex2D( _ToonTex, remappedRamp.xx).xyz;

				float3 finalColor = emissive + ((_ColorIntensity * baseColor * sphereMul + sphereAdd) * lerp(indirectLighting, directLighting, directContribution) * toonTexColor.rgb);
				fixed4 finalRGBA = fixed4(finalColor, _MainTex_var.a);			
				
				#if !defined(_ALPHABLEND_ON) && !defined(_ALPHAPREMULTIPLY_ON)
                    UNITY_OPAQUE_ALPHA(finalRGBA.a);
                #endif
				
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
			ZWrite Off
			LOD 200
			Cull Off
			Fog { Color (0,0,0,0) } // in additive pass fog should be black
			

			CGPROGRAM
			#pragma shader_feature NO_OUTLINE TINTED_OUTLINE COLORED_OUTLINE
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#include "FlatLitToonCoreMMD Extra.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#pragma only_renderers d3d11 glcore gles
			#pragma target 4.0
			
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			
			uniform sampler2D _DetailMap;
			float4 _DetailMap_ST;
			uniform sampler2D _DetailMapMask;
			float4 _DetailMapMask_ST;

			float4 frag(VertexOutput i) : COLOR
			{
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 _BumpMap_var = UnpackNormal(tex2D(_BumpMap, TRANSFORM_TEX((i.uv0 * _BumpMap_ST.xy + _BumpMap_ST.zw), _BumpMap)));
				float3 rampNormals = normalize(mul(_BumpMap_var.rgb, tangentTransform)); // Perturbed normals
				float3 _DetailMap_var = UnpackNormal(tex2D(_DetailMap, TRANSFORM_TEX((i.uv0 * _DetailMap_ST.xy + _DetailMap_ST.zw), _DetailMap)));
				float4 _DetailMapMask_var = tex2D(_DetailMapMask ,TRANSFORM_TEX(i.uv0, _DetailMapMask));
				_DetailMap_var *= _DetailMapMask_var.rgb;
				float3 normalDirection = normalize(mul((float3(_BumpMap_var.xy*_DetailMap_var.z + _DetailMap_var.xy*_BumpMap_var.z, _BumpMap_var.z*_DetailMap_var.z)), tangentTransform));
				
				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);
	
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float light_Env = float(any(_WorldSpaceLightPos0.xyz));
				if( light_Env != 1)
				{
						lightDirection = normalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
					
						if(length(unity_SHAr.xyz*unity_SHAr.w + unity_SHAg.xyz*unity_SHAg.w + unity_SHAb.xyz*unity_SHAb.w) == 0)
						{
							lightDirection = normalize(_DefaultLightDir.xyz);
						}
				}
	
				float4 _ColorMask_var = tex2D(_ColorMask,TRANSFORM_TEX(i.uv0, _ColorMask));
				float3 baseColor = lerp((_MainTex_var.rgb*_Color.rgb),_MainTex_var.rgb,_ColorMask_var.r);
				baseColor *= float4(i.col.rgb, 1);

				float lightContribution = dot(normalize(lightDirection - i.posWorld.xyz),normalDirection)*attenuation;
				float NdL = dot(normalDirection, float4(lightDirection.xyz, 0));
				float remappedRamp = (NdL * 0.5 + 0.5);
				float3 toonTexColor = tex2D( _ToonTex, remappedRamp.xx).xyz;
				
				float3 directContribution = floor(saturate(lightContribution) * 2.5);
				float3 finalColor = baseColor * lerp(0, _LightColor0.rgb, directContribution + attenuation) * toonTexColor.rgb;
				fixed4 finalRGBA = fixed4(finalColor * _MainTex_var.a, 1) * i.col;

				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}
			ENDCG
		}
		
		Pass
		{
			Name "SHADOW_CASTER"
			Tags{ "LightMode" = "ShadowCaster" }

			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
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
	FallBack "Diffuse"
	
	Fallback "Transparent/VertexLit"
	CustomEditor "RhyFlatLitMMDEditorDetail"
}