Shader "Rhy Frankensteins/Stealth(Cubed Setup)" 
{
    Properties 
	{
		//Stealth Properties
        _Stealth ("Stealth", Range(0, 1)) = 0.7378641
        _StealthScale ("StealthScale", Float ) = 2
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Emissive ("Emissive", 2D) = "black" {}
        _EmissiveColor ("Emissive Color", Color) = (1,1,1,1)
        _PBREmissiveIntensity ("PBREmissiveIntensity", Float ) = 1
        _BumpMap ("Normal Map", 2D) = "black" {}
        _NormalIntensity ("Normal Intensity", Range(0, 10)) = 1
        _Pattern ("Pattern", 2D) = "white" {}
        _EmissiveIntensity ("EmissiveIntensity", Float ) = 1
        _PatternColor ("Pattern Color", Color) = (1,1,1,1)
        _PatternSpeed ("PatternSpeed", Float ) = 0.1
        _PatternScale ("PatternScale", Float ) = 1
        [MaterialToggle] _StartTopBottom ("StartTop/Bottom", Float ) = 1
        [MaterialToggle] _VisibleEffect ("VisibleEffect", Float ) = 0
        _VisibleEffectIntensity ("VisibleEffectIntensity", Float ) = 1
        _MinVisibility ("Min Visibility", Range(0, 1)) = 0
        _RefractionIntensity ("RefractionIntensity", Float ) = 1
        [MaterialToggle] _TriplanarUV2 ("Triplanar/UV2", Float ) = 0
        [MaterialToggle] _PatternTriplanarUV1 ("PatternTriplanar/UV1", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		
		//Flat Lit Properties
		_Shadow("Shadow", Range(0, 1)) = 0.4
		_outline_width("outline_width", Float) = 0.2
		_outline_color("outline_color", Color) = (0.5,0.5,0.5,1)
		_outline_tint("outline_tint", Range(0, 1)) = 0.5
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		
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
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "DisableBatching"="True"
        }
        GrabPass{ "Refraction" }
        Pass 
		{
            Name "FORWARD"
            Tags 
			{
                "LightMode"="ForwardBase"
            }
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
            
            CGPROGRAM
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag
			#pragma shader_feature NO_OUTLINE TINTED_OUTLINE COLORED_OUTLINE
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #define UNITY_PASS_FORWARDBASE
            #define _GLOSSYENV 1
			#include "FlatLitToonCore.cginc"
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase
			#pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x n3ds wiiu 
            #pragma target 3.0
			
            uniform sampler2D Refraction;
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

            float4 frag(VertexOutput i) : COLOR {
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                #if UNITY_UV_STARTS_AT_TOP
                    float grabSign = -_ProjectionParams.x;
                #else
                    float grabSign = _ProjectionParams.x;
                #endif
                i.normalDir = normalize(i.normalDir);
                i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float4 _BumpMap_var = tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap));
                float3 normalLocal = float3((_BumpMap_var.rgb.rg*_NormalIntensity),1.0);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float node_7877 = _MainTex_var.a;
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
                float2 sceneUVs = float2(1,grabSign)*i.screenPos.xy*0.5+0.5 + ((node_7877*0.5)*saturate((clamp(((node_9778*(0.1*_RefractionIntensity))*saturate((node_9302+(node_3485+2.0)))),0,1)+saturate((node_9984*(_MinVisibility*0.1))))).rr);
                float4 sceneColor = tex2D(Refraction, sceneUVs);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
////// Lighting:
                float attenuation = 1;
////// Emissive:
                float4 _Emissive_var = tex2D(_Emissive,TRANSFORM_TEX(i.uv0, _Emissive));
                float node_1333 = (1.0 - ((10.0*node_9302)+node_9778+(((node_9984*0.1)+node_3485)*10.0+-5.0)));
                float node_1162 = (node_3485+node_9778+node_9302);
                float node_2121 = saturate(node_1162);
                float node_8264 = (lerp( 0.0, (pow(1.0-max(0,dot(normalDirection, viewDirection)),5.0)*3.0*(1.0 - node_2121)), _VisibleEffect )*_VisibleEffectIntensity);
                float3 emissive = ((_Emissive_var.rgb*_EmissiveColor.rgb*_PBREmissiveIntensity)+((saturate((_PatternColor.rgb*saturate((1.0 - (node_1333*(node_1333-(0.0+(10.0*node_1162))))))))*_EmissiveIntensity)+(_PatternColor.rgb*node_8264)));
/// Flat Lit Color
				float4 _ColorMask_var = tex2D(_ColorMask,TRANSFORM_TEX(i.uv0, _ColorMask));
				float4 baseColor = lerp((_MainTex_var.rgba*_Color.rgba),_MainTex_var.rgba,_ColorMask_var.r);
				baseColor *= float4(i.col.rgb, 1);
				
				#if COLORED_OUTLINE
				if(i.is_outline) 
				{
					baseColor.rgb = i.col.rgb; 
				}
				#endif

				#if defined(_ALPHATEST_ON)
        		clip (baseColor.a - _Cutoff);
    			#endif
				
				float3 reflectionMap = DecodeHDR(UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normalize((_WorldSpaceCameraPos - objPos.rgb)), 7), unity_SpecCube0_HDR)* 0.02;

				float grayscalelightcolor = dot(_LightColor0.rgb, grayscale_vector);
				float bottomIndirectLighting = grayscaleSH9(float3(0.0, -1.0, 0.0));
				float topIndirectLighting = grayscaleSH9(float3(0.0, 1.0, 0.0));
				float grayscaleDirectLighting = dot(lightDirection, normalDirection)*grayscalelightcolor*attenuation + grayscaleSH9(normalDirection);

				float lightDifference = topIndirectLighting + grayscalelightcolor - bottomIndirectLighting;
				float remappedLight = (grayscaleDirectLighting - bottomIndirectLighting) / lightDifference;

				float3 indirectLighting = saturate((ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)) + reflectionMap));
				float3 directLighting = saturate((ShadeSH9(half4(0.0, 1.0, 0.0, 1.0)) + reflectionMap + _LightColor0.rgb));
				float3 directContribution = saturate((1.0 - _Shadow) + floor(saturate(remappedLight) * 2.0));
				
/// Final Color:
                float3 finalColor = emissive + (baseColor * lerp(indirectLighting, directLighting, directContribution));;
                return fixed4(lerp(sceneColor.rgb, finalColor,(node_7877*saturate(((node_2121*1.0)+node_8264)))),1);
            }
            ENDCG
        }
        Pass 
		{
            Name "FORWARD_DELTA"
            Tags 
			{
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #define _GLOSSYENV 1
			#pragma shader_feature NO_OUTLINE TINTED_OUTLINE COLORED_OUTLINE
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#include "FlatLitToonCore.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x n3ds wiiu 
            #pragma target 3.0
            uniform sampler2D Refraction;
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

            float4 frag(VertexOutput i) : COLOR {
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                #if UNITY_UV_STARTS_AT_TOP
                    float grabSign = -_ProjectionParams.x;
                #else
                    float grabSign = _ProjectionParams.x;
                #endif
                i.normalDir = normalize(i.normalDir);
                i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float4 _BumpMap_var = tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap));
                float3 normalLocal = float3((_BumpMap_var.rgb.rg*_NormalIntensity),1.0);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float node_7877 = _MainTex_var.a;
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
                float2 sceneUVs = float2(1,grabSign)*i.screenPos.xy*0.5+0.5 + ((node_7877*0.5)*saturate((clamp(((node_9778*(0.1*_RefractionIntensity))*saturate((node_9302+(node_3485+2.0)))),0,1)+saturate((node_9984*(_MinVisibility*0.1))))).rr);
                float4 sceneColor = tex2D(Refraction, sceneUVs);
////// Lighting:
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);
                float3 attenColor = attenuation * _LightColor0.xyz;
				
/// Flat Lit Color				
				float4 _ColorMask_var = tex2D(_ColorMask,TRANSFORM_TEX(i.uv0, _ColorMask));
				float4 baseColor = lerp((_MainTex_var.rgba*_Color.rgba),_MainTex_var.rgba,_ColorMask_var.r);
				baseColor *= float4(i.col.rgb, 1);

				#if COLORED_OUTLINE
				if(i.is_outline) {
					baseColor.rgb = i.col.rgb;
				}
				#endif

				#if defined(_ALPHATEST_ON)
        		clip (baseColor.a - _Cutoff);
    			#endif

				float lightContribution = dot(normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz),normalDirection)*attenuation;
				float3 directContribution = floor(saturate(lightContribution) * 2.0);
			
/// Final Color:
                float3 finalColor = baseColor * lerp(0, _LightColor0.rgb, saturate(directContribution + ((1 - _Shadow) * attenuation)));
                float node_1162 = (node_3485+node_9778+node_9302);
                float node_2121 = saturate(node_1162);
                float node_8264 = (lerp( 0.0, (pow(1.0-max(0,dot(normalDirection, viewDirection)),5.0)*3.0*(1.0 - node_2121)), _VisibleEffect )*_VisibleEffectIntensity);
                return (fixed4(finalColor * (node_7877*saturate(((node_2121*1.0)+node_8264))),0) * i.col);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "StealthMaterialInspector"
}