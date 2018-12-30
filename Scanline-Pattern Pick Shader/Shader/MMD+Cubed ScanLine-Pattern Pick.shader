// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33486,y:32294,varname:node_3138,prsc:2|custl-313-OUT;n:type:ShaderForge.SFN_Tex2d,id:7464,x:32701,y:32641,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_7464,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:6405,x:32701,y:32828,ptovrint:False,ptlb:Secondary,ptin:_Secondary,varname:node_6405,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Time,id:984,x:32028,y:32397,varname:node_984,prsc:2;n:type:ShaderForge.SFN_Sin,id:6579,x:32449,y:32323,varname:node_6579,prsc:2|IN-7880-OUT;n:type:ShaderForge.SFN_Multiply,id:803,x:32230,y:32359,varname:node_803,prsc:2|A-2125-OUT,B-984-T;n:type:ShaderForge.SFN_ValueProperty,id:2125,x:32028,y:32339,ptovrint:False,ptlb:speed,ptin:_speed,varname:node_2125,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Slider,id:1976,x:32421,y:32213,ptovrint:False,ptlb:ramp,ptin:_ramp,varname:node_1976,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5,max:1;n:type:ShaderForge.SFN_Color,id:2109,x:33084,y:32373,ptovrint:False,ptlb:Tint,ptin:_Tint,varname:node_2109,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:313,x:33304,y:32532,varname:node_313,prsc:2|A-2109-RGB,B-2070-OUT,C-8657-OUT;n:type:ShaderForge.SFN_Multiply,id:3413,x:32915,y:32531,varname:node_3413,prsc:2|A-2814-OUT,B-7464-RGB;n:type:ShaderForge.SFN_Add,id:7880,x:32230,y:32213,varname:node_7880,prsc:2|A-6585-V,B-803-OUT;n:type:ShaderForge.SFN_ScreenPos,id:6585,x:32028,y:32158,varname:node_6585,prsc:2,sctp:0;n:type:ShaderForge.SFN_OneMinus,id:9126,x:32701,y:32478,varname:node_9126,prsc:2|IN-6579-OUT;n:type:ShaderForge.SFN_Multiply,id:4700,x:32915,y:32719,varname:node_4700,prsc:2|A-9126-OUT,B-6405-RGB;n:type:ShaderForge.SFN_Blend,id:2070,x:33122,y:32667,varname:node_2070,prsc:2,blmd:5,clmp:True|SRC-3413-OUT,DST-4700-OUT;n:type:ShaderForge.SFN_Divide,id:2814,x:32834,y:32322,varname:node_2814,prsc:2|A-1976-OUT,B-6579-OUT;n:type:ShaderForge.SFN_Multiply,id:3027,x:33174,y:32938,varname:node_3027,prsc:2|A-6436-RGB,B-9514-OUT;n:type:ShaderForge.SFN_LightAttenuation,id:9514,x:32915,y:33048,varname:node_9514,prsc:2;n:type:ShaderForge.SFN_LightColor,id:6436,x:32915,y:32928,varname:node_6436,prsc:2;n:type:ShaderForge.SFN_Vector3,id:6859,x:33345,y:32830,varname:node_6859,prsc:2,v1:0.5,v2:0.5,v3:0.5;n:type:ShaderForge.SFN_Add,id:8657,x:33494,y:32917,varname:node_8657,prsc:2|A-6859-OUT,B-3027-OUT;proporder:7464-6405-2125-1976-2109;pass:END;sub:END;*/

Shader "Rhy Custom Shaders/MMD+Cubed Scanline - Toggle"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Secondary ("Secondary", 2D) = "white" {}
		_speed ("speed", Float ) = 1
        _ramp ("ramp", Range(0, 1)) = 0.5
		_swap ("swap", Range(-1, 1)) = 1
        _Tint ("Tint", Color) = (1,1,1,1)
		_Color("Color", Color) = (1,1,1,1)
		_ColorMask("ColorMask", 2D) = "black" {}
		_SphereAddTex("Sphere Add Texture", 2D) = "black" {}
		_SphereAddIntensity("Add Sphere Texture Intensity", Range(0, 5)) = 1.0
		_SphereMulTex("Sphere Multiply Texture", 2D) = "white" {}
		_SphereMulIntensity("Multiply Sphere Texture Intensity", Range(0, 5)) = 1.0
		_ToonTex("Toon Texture", 2D) = "white" {}
		_outline_width("outline_width", Float) = 0.2
		_outline_color("outline_color", Color) = (0.5,0.5,0.5,1)
		_outline_tint("outline_tint", Range(0, 1)) = 0.5
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_BumpMap("BumpMap", 2D) = "bump" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5

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
			"RenderType" = "Opaque"
		}

		Pass
		{

			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			CGPROGRAM
			#include "FlatLitToonCore MMD.cginc"
			#pragma shader_feature NO_OUTLINE TINTED_OUTLINE COLORED_OUTLINE
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			uniform sampler2D _Secondary; uniform float4 _Secondary_ST;
			uniform float _speed;
            uniform float _ramp;
			uniform float _swap;
            uniform float4 _Tint;
			
			float4 frag(VertexOutput i) : COLOR
			{
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				float2 sceneUVs = (objPos.xy / objPos.w);
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 _BumpMap_var = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap)));
				float3 normalDirection = normalize(mul(_BumpMap_var.rgb, tangentTransform)); // Perturbed normals
				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				float4 _Secondary_var = tex2D(_Secondary,TRANSFORM_TEX(i.uv0, _Secondary));
				
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 lightColor = _LightColor0.rgb;
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);

				float4 _EmissionMap_var = tex2D(_EmissionMap,TRANSFORM_TEX(i.uv0, _EmissionMap));
				float3 emissive = (_EmissionMap_var.rgb*_EmissionColor.rgb);
				float4 _ColorMask_var = tex2D(_ColorMask,TRANSFORM_TEX(i.uv0, _ColorMask));
				float4 baseColor = lerp((_MainTex_var.rgba*_Color.rgba),_MainTex_var.rgba,_ColorMask_var.r);
				baseColor *= float4(i.col.rgb, 1);

				// MMD Spheres
				float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_V, normalDirection));
				float2 sphereUV = viewNormal.xy * 0.5 + 0.5;
				float4 sphereAdd = tex2D(_SphereAddTex, sphereUV);
				sphereAdd.rgb *= _SphereAddIntensity;
				float4 sphereMul = tex2D(_SphereMulTex, sphereUV);
				sphereMul.rgb *= _SphereMulIntensity;

				#if COLORED_OUTLINE
				if(i.is_outline) 
				{
					baseColor.rgb = i.col.rgb; 
					sphereAdd = 0;
					sphereMul = 1;
				}
				#endif

				#if defined(_ALPHATEST_ON)
        		clip (baseColor.a - _Cutoff);
    			#endif
				
				float3 lightmap = float4(1.0,1.0,1.0,1.0);
				#ifdef LIGHTMAP_ON
				lightmap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1 * unity_LightmapST.xy + unity_LightmapST.zw));
				#endif

				float3 reflectionMap = DecodeHDR(UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normalize((_WorldSpaceCameraPos - objPos.rgb)), 7), unity_SpecCube0_HDR)* 0.02;

				float grayscalelightcolor = dot(_LightColor0.rgb, grayscale_vector);
				float bottomIndirectLighting = grayscaleSH9(float3(0.0, -1.0, 0.0));
				float topIndirectLighting = grayscaleSH9(float3(0.0, 1.0, 0.0));

				normalDirection = normalize(mul(_BumpMap_var.rgb, tangentTransform)); 

				float grayscaleDirectLighting = dot(lightDirection, normalDirection)*grayscalelightcolor*attenuation + grayscaleSH9(normalDirection);

				float lightDifference = topIndirectLighting + grayscalelightcolor - bottomIndirectLighting;
				float remappedLight = (grayscaleDirectLighting - bottomIndirectLighting) / lightDifference;
				float3 indirectLighting = saturate((ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)) + reflectionMap));
				float3 directLighting = saturate((ShadeSH9(half4(0.0, 1.0, 0.0, 1.0)) + reflectionMap + _LightColor0.rgb));
				float3 directContribution = saturate((1.0 - 0.0) + floor(saturate(remappedLight) * 2.0));
				float transition = sin((sceneUVs * 2 - 1).g + (_speed * _swap));
				
				float4 toonTexColor = tex2D(_ToonTex, float2(0.5, dot(lightDirection, normalDirection) * 0.5 + 0.5));
				float3 finalColor = emissive + ((_Tint.rgb*saturate(max(((_ramp/transition)*_MainTex_var.rgb),((1.0 - transition)*_Secondary_var.rgb)))) * sphereMul + sphereAdd) * lerp(indirectLighting, directLighting, saturate(directContribution * toonTexColor));

				fixed4 finalRGBA = fixed4(finalColor * lightmap, baseColor.a);
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

			CGPROGRAM
			#pragma shader_feature NO_OUTLINE TINTED_OUTLINE COLORED_OUTLINE
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#include "FlatLitToonCore MMD.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			
			uniform sampler2D _Secondary; uniform float4 _Secondary_ST;
			uniform float _speed;
            uniform float _ramp;
			uniform float _swap;
            uniform float4 _Tint;

			float4 frag(VertexOutput i) : COLOR
			{
				float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				float2 sceneUVs = (objPos.xy / objPos.w);
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 _BumpMap_var = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap)));
				float3 normalDirection = normalize(mul(_BumpMap_var.rgb, tangentTransform)); // Perturbed normals
				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				float4 _Secondary_var = tex2D(_Secondary,TRANSFORM_TEX(i.uv0, _Secondary));

				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 lightColor = _LightColor0.rgb;
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);
	
				float4 _ColorMask_var = tex2D(_ColorMask,TRANSFORM_TEX(i.uv0, _ColorMask));
				float4 baseColor = lerp((_MainTex_var.rgba*_Color.rgba),_MainTex_var.rgba,_ColorMask_var.r);
				baseColor *= float4(i.col.rgb, 1);

				// MMD Spheres
				float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_V, normalDirection));
				float2 sphereUV = viewNormal.xy * 0.5 + 0.5;
				float4 sphereAdd = tex2D(_SphereAddTex, sphereUV);
				sphereAdd.rgb *= _SphereAddIntensity;
				float4 sphereMul = tex2D(_SphereMulTex, sphereUV);
				sphereMul.rgb *= _SphereMulIntensity;

				#if COLORED_OUTLINE
				if(i.is_outline) {
					baseColor.rgb = i.col.rgb;
					sphereAdd = 0;
					sphereMul = 1;
				}
				#endif

				#if defined(_ALPHATEST_ON)
        		clip (baseColor.a - _Cutoff);
    			#endif

    			float lightContribution = dot(normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz),normalDirection)*attenuation;
				float3 directContribution = floor(saturate(lightContribution) * 2.0);
				float transition = sin((sceneUVs * 2 - 1).g + (_speed * _swap));

				float4 toonTexColor = tex2D(_ToonTex, float2(0.5, dot(lightDirection, normalDirection) * 0.5 + 0.5));
				float3 finalColor = ((_Tint.rgb*saturate(max(((_ramp/transition)*_MainTex_var.rgb),((1.0 - transition)*_Secondary_var.rgb)))) * sphereMul + sphereAdd) * lerp(0, _LightColor0.rgb, saturate(directContribution * toonTexColor + attenuation));
				fixed4 finalRGBA = fixed4(finalColor,1) * i.col;
				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}
			ENDCG
		}

		Pass
		{
			Name "SHADOW_CASTER"
			Tags{ "LightMode" = "ShadowCaster" }

			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#include "FlatLitToonShadows.cginc"
			
			#pragma multi_compile_shadowcaster

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			ENDCG
		}
	}
	FallBack "Diffuse"
	CustomEditor "ShaderForgeMaterialInspector"
}