// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
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
		_NormalIntensity("Normal Intensity", Range(0,5)) = 1
		_NormalMask("Normal Mask", 2D) = "White" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		_Opacity("Opacity", Range(1,0)) = 0
		_SpecularBleed("Specular Bleedthrough", Range(0,1)) = 0.1
		_ClampMin("Minimum Light Intensity", Range(0,3)) = 0
		_ClampMax("Maximum Light Intensity", Range(1,5)) = 5
		_EmissionToggle("Emission Toggle", Float) = 0

		_squeeze("squeeze", Range( 0 , 0.2)) = 0
		_SqueezeDist("SqueezeDist", Range( 0 , 0.1)) = 0
		_BulgeOffset("BulgeOffset", Range( 0 , 0.3)) = 0
		_BulgePower("BulgePower", Range( 0 , 0.01)) = 0
		_Length("Penetrator Length", Range( 0 , 3)) = 0
		_EntranceStiffness("EntranceStiffness", Range( 0.01 , 1)) = 0
		_Curvature("Curvature", Range( -1 , 1)) = 0
		_ReCurvature("ReCurvature", Range( -1 , 1)) = 0
		_WriggleSpeed("WriggleSpeed", Range( 0.1 , 30)) = 0.28
		_Wriggle("Wriggle", Range( 0 , 1)) = 0.28
		_OrificeChannel("OrificeChannel Please Use 0", Float) = 0

		// Blending state
		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _Cull ("__cull", Float) = 0.0
		[HideInInspector] _OutlineMode("__outline_mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[HideInInspector] _StencilRef("Stencil Reference Value", Range(0, 255)) = 100
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" }

		Stencil
		{
			Ref[_StencilRef]
			Comp Always
			Pass Replace
		}

		Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
		Cull Off

		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "PenCore.cginc"
		#include "PenHelperFunction.cginc"
		#include "DPSBlacklights.cginc"
		#pragma target 3.0
		#pragma multi_compile __ _TOONSHADING_ON
		#pragma surface surf StandardCustomLighting keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
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
		uniform float _EntranceStiffness;
		uniform float _Length;
		uniform float _WriggleSpeed;
		uniform float _Wriggle;
		uniform float _Curvature;
		uniform float _ReCurvature;
		uniform float _squeeze;
		uniform float _SqueezeDist;
		uniform float _BulgePower;
		uniform float _BulgeOffset;
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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float orificeType = 0;
			float3 orificePositionTracker = float3(0,0,100);
			float3 orificeNormalTracker = float3(0,0,99);
			float3 penetratorPositionTracker = float3(0,0,1);
			float pl=0;
			GetBestLights(_OrificeChannel, orificeType, orificePositionTracker, orificeNormalTracker, penetratorPositionTracker, pl);
			float3 orificeNormal = normalize( lerp( ( orificePositionTracker - orificeNormalTracker ) , orificePositionTracker , max( _EntranceStiffness , 0.01 )) );
			float3 PhysicsNormal = normalize(penetratorPositionTracker.xyz) * _Length * 0.3;
			float wriggleTime = _Time.y * _WriggleSpeed;
			float temp_output_257_0 = ( _Length * ( ( cos( wriggleTime ) * _Wriggle ) + _Curvature ) );
			float wiggleTime = _Time.y * ( _WriggleSpeed * 0.39 );
			float distanceToOrifice = length( orificePositionTracker );
			float enterFactor = smoothstep( ( _Length + -0.05 ) , _Length , distanceToOrifice);
			float3 finalOrificeNormal = normalize( lerp( orificeNormal , ( PhysicsNormal + ( ( float3(0,1,0) * ( temp_output_257_0 + ( _Length * ( _ReCurvature + ( ( sin( wriggleTime ) * 0.3 ) * _Wriggle ) ) * 2.0 ) ) ) + ( float3(0.5,0,0) * ( cos( wiggleTime ) * _Wriggle ) ) ) ) , enterFactor) );
			float smoothstepResult186 = smoothstep( _Length , ( _Length + 0.05 ) , distanceToOrifice);
			float3 finalOrificePosition = lerp( orificePositionTracker , ( ( normalize(penetratorPositionTracker) * _Length ) + ( float3(0,0.2,0) * ( sin( ( wriggleTime + UNITY_PI ) ) * _Wriggle ) * _Length ) + ( float3(0.2,0,0) * _Length * ( sin( ( wiggleTime + UNITY_PI ) ) * _Wriggle ) ) ) , smoothstepResult186);
			float finalOrificeDistance = length( finalOrificePosition );
			float3 bezierBasePosition = float3(0,0,0);
			float temp_output_59_0 = ( finalOrificeDistance / 3.0 );
			float3 lerpResult274 = lerp( float3( 0,0,0 ) , ( float3(0,1,0) * ( temp_output_257_0 * -0.2 ) ) , saturate( ( distanceToOrifice / _Length ) ));
			float3 temp_output_267_0 = ( ( temp_output_59_0 * float3(0,0,1) ) + lerpResult274 );
			float3 bezierBaseNormal = temp_output_267_0;
			float3 temp_output_63_0 = ( finalOrificePosition - ( temp_output_59_0 * finalOrificeNormal ) );
			float3 bezierOrificeNormal = temp_output_63_0;
			float3 bezierOrificePosition = finalOrificePosition;
			float vertexBaseTipPosition = ( v.vertex.z / finalOrificeDistance );
			float t = saturate(vertexBaseTipPosition);
			float oneMinusT = 1 - t;
			float3 bezierPoint = oneMinusT * oneMinusT * oneMinusT * bezierBasePosition + 3 * oneMinusT * oneMinusT * t * bezierBaseNormal + 3 * oneMinusT * t * t * bezierOrificeNormal + t * t * t * bezierOrificePosition;
			float3 straightLine = (float3(0.0 , 0.0 , v.vertex.z));
			float baseFactor = smoothstep( 0.05 , -0.05 , v.vertex.z);
			bezierPoint = lerp( bezierPoint , straightLine , baseFactor);
			bezierPoint = lerp( ( ( finalOrificeNormal * ( v.vertex.z - finalOrificeDistance ) ) + finalOrificePosition ) , bezierPoint , step( vertexBaseTipPosition , 1.0 ));
			float3 bezierDerivitive = 3 * oneMinusT * oneMinusT * (bezierBaseNormal - bezierBasePosition) + 6 * oneMinusT * t * (bezierOrificeNormal - bezierBaseNormal) + 3 * t * t * (bezierOrificePosition - bezierOrificeNormal);
			bezierDerivitive = normalize( lerp( bezierDerivitive , float3(0,0,1) , baseFactor) );
			float bezierUpness = dot( bezierDerivitive , float3( 0,1,0 ) );
			float3 bezierUp = lerp( float3(0,1,0) , float3( 0,0,-1 ) , saturate( bezierUpness ));
			float bezierDownness = dot( bezierDerivitive , float3( 0,-1,0 ) );
			bezierUp = normalize( lerp( bezierUp , float3( 0,0,1 ) , saturate( bezierDownness )) );
			float3 bezierSpaceX = normalize( cross( bezierDerivitive , bezierUp ) );
			float3 bezierSpaceY = normalize( cross( bezierDerivitive , -bezierSpaceX ) );
			float3 bezierSpaceVertexOffset = ( ( v.vertex.y * bezierSpaceY ) + ( v.vertex.x * -bezierSpaceX ) );
			float3 bezierSpaceVertexOffsetNormal = normalize( bezierSpaceVertexOffset );
			float distanceFromTip = ( finalOrificeDistance - v.vertex.z );
			float squeezeFactor = smoothstep( 0.0 , _SqueezeDist , -distanceFromTip);
			squeezeFactor = max( squeezeFactor , smoothstep( 0.0 , _SqueezeDist , distanceFromTip));
			float3 bezierSpaceVertexOffsetSqueezed = lerp( ( bezierSpaceVertexOffsetNormal * min( length( bezierSpaceVertexOffset ) , _squeeze ) ) , bezierSpaceVertexOffset , squeezeFactor);
			float bulgeFactor = smoothstep( 0.0 , _BulgeOffset , abs( ( finalOrificeDistance - v.vertex.z ) ));
			float bulgeFactorBaseClip = smoothstep( 0.0 , 0.05 , v.vertex.z);
			float bezierSpaceVertexOffsetBulged = lerp( 1.0 , ( 1.0 + _BulgePower ) , ( ( 1.0 - bulgeFactor ) * 100.0 * bulgeFactorBaseClip ));
			float3 bezierSpaceVertexOffsetFinal = lerp( ( bezierSpaceVertexOffsetSqueezed * bezierSpaceVertexOffsetBulged ) , bezierSpaceVertexOffset , enterFactor);
			float3 bezierConstructedVertex = ( bezierPoint + bezierSpaceVertexOffsetFinal );
			float3 sphereifyDistance = ( bezierConstructedVertex - finalOrificePosition );
			float3 sphereifyNormal = normalize( sphereifyDistance );
			float sphereifyFactor = smoothstep( 0.05 , -0.05 , distanceFromTip);
			float killSphereifyForRing = lerp( sphereifyFactor , 0.0 , orificeType);
			bezierConstructedVertex = lerp( bezierConstructedVertex , ( ( min( length( sphereifyDistance ) , _squeeze ) * sphereifyNormal ) + finalOrificePosition ) , killSphereifyForRing);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			bezierConstructedVertex = lerp( bezierConstructedVertex , ( -ase_worldViewDir * float3( 10000,10000,10000 ) ) , _WorldSpaceLightPos0.w);
			v.normal = normalize( ( ( -bezierSpaceX * v.normal.x ) + ( bezierSpaceY * v.normal.y ) + ( bezierDerivitive * v.normal.z ) ) );
			v.vertex.xyz = bezierConstructedVertex;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;

			float4 white = float4(1,1,1,1);
			float4 black = float4(0,0,0,0);
			float light_Env = float(any(_WorldSpaceLightPos0.xyz));
			float4 lightColor = float4(_LightColor0.rgb, _LightColor0.w);
			float AvgIntensity = (_LightColor0.r + _LightColor0.g + _LightColor0.b)/3;

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
			//attenuation = FadeShadows(attenuation, i.worldPos.xyz);

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
				
			tempValue = (tempValue + shadowMask_var.rgb);
			Lighting.indirectLit += ((shadowTexColor + (.75 * shadowMask_var.rgb)) * Lighting.lightCol);

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
			if(_Mode == 4)
			{
				finalAlpha = _Opacity;
				_ColorIntensity *= _Opacity;
				Matcap.Add *= _Opacity;
				sphereSubAdd *= _Opacity;
			}

			float3 finalColor = emissive + (Matcap.Add + (_ColorIntensity * (baseColor.rgb * toonTexColor) * Matcap.Mul)) * (lerp(Lighting.indirectLit, Lighting.directLit, attenuation));

			if(light_Env != 1)
				finalColor = emissive + (Matcap.Add + (_ColorIntensity * (baseColor.rgb * toonTexColor) * Matcap.Mul)) * Lighting.lightCol;

			c.rgb = finalColor;
			c.a = finalAlpha;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf(Input i, inout SurfaceOutputCustomLightingCustom o)
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
	CustomEditor "RhyPenEditor"
}
/*ASEBEGIN
Version=18707
17;28;1211;1004;8411.379;817.428;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;232;-7645.52,-1994.103;Inherit;False;1164.216;667.5702;;18;387;389;197;388;159;209;208;213;211;163;162;228;226;227;231;390;459;460;Light Extraction;1,0.8909494,0.4858491,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-8303.876,-1616.121;Inherit;False;Property;_OrificeChannel;OrificeChannel Please Use 0;23;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;347;-7975.114,-397.0112;Inherit;False;Property;_WriggleSpeed;WriggleSpeed;16;0;Create;True;0;0;False;0;False;0.28;6.2;0.1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-7037.576,-1829.861;Inherit;False;Constant;_ID_Physics;ID_Physics;17;0;Create;True;0;0;False;0;False;0.09;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;346;-7348.816,-394.7921;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;226;-6906.834,-1924.846;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CustomExpressionNode;227;-6861.972,-1823.136;Inherit;False;for (int i=0@i<4@i++) {$float range = (0.005 * sqrt(1000000 - unity_4LightAtten0[i])) / sqrt(unity_4LightAtten0[i])@$if (length(unity_LightColor[i].rgb) < 0.0001 && abs(fmod(range,0.1)-ID)<0.01) {$return float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1)@$}$}$return float4(0,-10000,0,1)@;4;False;1;True;ID;FLOAT;0;In;;Inherit;False;ExtractLightByID;True;False;0;1;0;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StepOpNode;391;-7974.582,-1630.064;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-7354.378,-1517.702;Inherit;False;Constant;_ID_Orifice;ID_Orifice;15;0;Create;True;0;0;False;0;False;0.01;1.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;348;-7071.924,-393.936;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-7430.77,-1430.915;Inherit;False;Constant;_ID_OrificePassthrough;ID_OrificePassthrough;15;0;Create;True;0;0;False;0;False;0.02;1.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;-6668.543,-1892.317;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;387;-7329.894,-1624.705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;383;-7519.877,-128.4054;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.39;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;-6912.056,-399.9368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-7478.407,-601.4678;Inherit;False;Property;_Wriggle;Wriggle;17;0;Create;True;0;0;False;0;False;0.28;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;349;-7073.531,-497.6057;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;390;-7067.096,-1535.871;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;344;-6202.321,-700.5735;Inherit;False;976.3345;339.8781;;6;261;260;272;257;351;256;Curvature;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;345;-6384.752,-311.8493;Inherit;False;1642.985;393.245;;11;292;275;276;274;266;265;271;273;270;268;350;Recurvature;1,1,1,1;0;0
Node;AmplifyShaderEditor.PiNode;379;-7315.166,69.34233;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;460;-7323.035,-1721.973;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;360;-7303.016,-241.0932;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;389;-7069.693,-1437.206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;333;-6438.924,-1955.064;Inherit;False;234.022;169.6084;;1;229;Physics Position;0.5359211,0,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-7342.125,-1810.538;Inherit;False;Constant;_ID_Normal;ID_Normal;16;0;Create;True;0;0;False;0;False;0.05;1.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;374;-7360.966,-84.35659;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;342;-6545.562,-2137.332;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-6679.407,-518.4678;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;256;-6175.266,-484.4696;Inherit;False;Property;_Curvature;Curvature;14;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;459;-7061.693,-1649.842;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;375;-7082.758,24.5428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;-6681.407,-417.4678;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;270;-6364.845,-127.0617;Inherit;False;Property;_ReCurvature;ReCurvature;15;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;353;-7070.608,-285.8927;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;343;-6394.761,-2121.731;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;-9000;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;159;-6837.196,-1455.196;Inherit;False;for (int i=0@i<4@i++)${$float range = (0.005 * sqrt(1000000 - unity_4LightAtten0[i])) / sqrt(unity_4LightAtten0[i])@$if (length(unity_LightColor[i].rgb) < 0.0001)${$if (abs(fmod(range,0.1)-ID)<0.005)${$OrificeType=0@$return float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1)@$}$if (abs(fmod(range,0.1)-ID2)<0.005)${$OrificeType=1@$return float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1)@$}$}$}$return float4(0,-1000,0,1)@;4;False;3;True;ID;FLOAT;0;In;;Inherit;False;True;ID2;FLOAT;0;In;;Inherit;False;True;OrificeType;FLOAT;0;Out;;Inherit;False;ExtractLightByID;True;False;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;2;FLOAT4;0;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;229;-6390.71,-1894.168;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;162;-6829.897,-1546.097;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.Vector3Node;341;-6593.663,-2281.631;Inherit;False;Constant;_Vector5;Vector 5;15;0;Create;True;0;0;False;0;False;0,0,0.2;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;185;-7112.586,-730.0186;Inherit;False;Property;_Length;Penetrator Length;12;0;Create;False;0;0;False;0;False;0;0.3541295;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;238;-5454.581,-1290.952;Inherit;False;569.6211;573.0204;;8;357;358;245;246;244;359;372;373;Physics Position;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;350;-6040.621,-137.0198;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;335;-6439.499,-1558.374;Inherit;False;234.022;169.6084;;1;192;OrificePosition;0.5359211,0,1,1;0;0
Node;AmplifyShaderEditor.SinOpNode;361;-6920.379,-274.6895;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;340;-6141.258,-1913.731;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-6022.945,-33.94936;Inherit;False;Constant;_Float2;Float 2;14;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;208;-6909.16,-1737.034;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CommentaryNode;237;-4581.625,-1125.311;Inherit;False;656.4952;371.9169;;5;191;186;241;187;193;Range Adjusted Orifice Position;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-6612.746,-1491.265;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SinOpNode;378;-6932.529,35.74599;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;213;-6860.699,-1636.324;Inherit;False;for (int i=0@i<4@i++) {$float range = (0.005 * sqrt(1000000 - unity_4LightAtten0[i])) / sqrt(unity_4LightAtten0[i])@$if (length(unity_LightColor[i].rgb) < 0.0001 && abs(fmod(range,0.1)-ID)<0.005) {$return float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1)@$}$}$return float4(0,-1000,0,1)@;4;False;1;True;ID;FLOAT;0;In;;Inherit;False;ExtractLightByID;True;False;0;1;0;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;351;-5882.5,-504.313;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;192;-6397.402,-1493.836;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;-5826.964,-143.4476;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;364;-6679.407,-311.4678;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;384;-7073.774,156.1855;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;257;-5738.183,-496.8688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;-6691.557,-1.032297;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;372;-5429.758,-884.6739;Inherit;False;Constant;_Vector8;Vector 8;13;0;Create;True;0;0;False;0;False;0.2,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;246;-5438.75,-1138.908;Inherit;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;359;-5435.476,-1042.949;Inherit;False;Constant;_Vector6;Vector 6;16;0;Create;True;0;0;False;0;False;0,0.2,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;244;-5435.315,-1237.032;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;241;-4544.471,-932.0718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-6664.19,-1693.819;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;334;-6439.498,-1756.812;Inherit;False;234.022;169.6084;;1;214;OrificeNormalPosition;0.5359211,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;235;-4842.188,-1285.92;Inherit;False;160.8896;142.3582;;1;236;Orifice Position;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;272;-5571.532,-493.5397;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;260;-5595.525,-649.3993;Inherit;False;Constant;_Vector2;Vector 2;13;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;-5234.961,-1029.597;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;370;-5171.843,-530.0591;Inherit;False;Constant;_Vector7;Vector 7;13;0;Create;True;0;0;False;0;False;0.5,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;373;-5244.09,-862.2254;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;193;-4542.336,-1066.034;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;245;-5264.984,-1229.147;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;385;-6688.752,109.8354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;187;-4415.836,-869.734;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;236;-4818.362,-1238.267;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;234;-4488.993,-1625.6;Inherit;False;561.9852;333.7177;;4;217;462;461;466;Orifice Normal ;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;214;-6399.27,-1699.083;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;277;-4243.396,-2001.333;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;357;-5073.611,-1232.58;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-4986.175,-507.6107;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;462;-4453.993,-1447.86;Inherit;False;Property;_EntranceStiffness;EntranceStiffness;13;0;Create;True;0;0;False;0;False;0;0.01;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-5403.209,-593.4473;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;240;-4508.048,-668.3204;Inherit;False;489.4006;312.6721;Comment;2;259;467;Physics Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;186;-4275.564,-987.2419;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;217;-4457.25,-1570.42;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;461;-4149.032,-1572.304;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;467;-4460.464,-606.9095;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;369;-4827.639,-632.6225;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;262;-4250.226,-2103.563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;191;-4095.535,-1072.055;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;280;-4111.97,-2043.641;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;160;-3849.918,-913.1038;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;276;-5442.513,-66.93636;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;279;-3974.491,-2056.503;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;466;-4080.254,-1417.608;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;259;-4246.734,-577.3895;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;239;-3841.161,-1211.23;Inherit;False;566.2222;232.2317;;2;73;216;Range Adjusted Orifice Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;216;-3717.261,-1137.061;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;264;-3802.019,-739.2534;Inherit;False;592.4695;387.1287;;4;267;61;59;62;Base Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;265;-5619.5,-235.3224;Inherit;False;Constant;_Vector4;Vector 4;13;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LengthOpNode;32;-4060.999,65.44838;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-6056.925,-253.759;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;275;-5279.076,-27.34711;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;73;-3534.202,-1131.75;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;59;-3732.552,-475.3417;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;6;-5123.261,136.776;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;-5377.611,-199.2279;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;62;-3758.943,-663.3293;Inherit;False;Constant;_Vector3;Vector 3;3;0;Create;True;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;250;-2841.98,-1126.037;Inherit;False;997.4197;772.9243;;12;251;63;72;58;67;88;90;17;57;252;65;269;Bezier Z;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;292;-5117.367,-69.08905;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;252;-2773.837,-958.4879;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;110;-3403.696,175.5219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-3549.134,-585.8937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;274;-4924.931,-216.0581;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2639.718,-845.8173;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;267;-3361.284,-661.5206;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;251;-2631.944,-722.076;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-2479.18,-873.0175;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;65;-2478.793,-640.9208;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2481.325,-1076.468;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;67;-2224.629,-633.7161;Inherit;False;t = saturate(t)@$float oneMinusT = 1 - t@$return 3 * oneMinusT * oneMinusT * (P1 - P0) + 6 * oneMinusT * t * (P2 - P1) + 3 * t * t * (P3 - P2)@;3;False;5;True;P0;FLOAT3;0,0,0;In;;Inherit;False;True;P1;FLOAT3;0,0,0;In;;Inherit;False;True;P2;FLOAT3;0,0,0;In;;Inherit;False;True;P3;FLOAT3;0,0,0;In;;Inherit;False;True;t;FLOAT;0;In;;Inherit;False;BezierDerivative;True;False;0;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;269;-2224.195,-779.145;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;-0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;88;-2017.49,-545.421;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;85;-1660.856,-525.3486;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;299;-2224.849,578.928;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;298;-2058.876,581.0798;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;50;-1359.871,723.4724;Inherit;False;1481.979;277.6533;;11;38;42;24;23;22;19;20;21;18;81;84;CurveSpaceOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;18;-1337.849,849.4976;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;303;-2055.689,689.6642;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,-1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;300;-1921.773,583.1935;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;297;-1730.641,561.0457;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,-1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;304;-1929.662,685.9578;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;301;-1554.722,688.186;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;20;-1159.18,778.3375;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;21;-1154.092,860.8547;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;19;-1003.408,799.2985;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;38;-833.9291,865.3237;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;84;-673.7865,869.2846;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;22;-520.4558,787.9975;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;81;-356.0467,795.8895;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-185.6305,783.5836;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-187.0678,884.7827;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;165;-4656.799,422.0729;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;253;655.0454,309.1463;Inherit;False;889.9656;453.5916;;9;108;107;109;102;106;104;103;331;332;Squeeze;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-26.84427,821.6576;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-4977.612,799.0469;Inherit;False;Property;_BulgeOffset;BulgeOffset;10;0;Create;True;0;0;False;0;False;0;0.139;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;166;-4458.236,416.1838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;342.2459,353.5897;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;691.3577,424.9187;Inherit;False;Property;_SqueezeDist;SqueezeDist;9;0;Create;True;0;0;False;0;False;0;0.0289;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;167;-4338.786,424.5096;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;330;815.9143,211.0393;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;103;685.8696,681.6411;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2274.468,199.5293;Inherit;False;Property;_squeeze;squeeze;8;0;Create;True;0;0;False;0;False;0;0.0266;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-4186.572,626.1499;Inherit;False;Constant;_Float13;Float 13;9;0;Create;True;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;102;991.8451,364.8023;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;106;999.1681,576.0912;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-4976.817,883.2764;Inherit;False;Property;_BulgePower;BulgePower;11;0;Create;True;0;0;False;0;False;0;0.00272;0;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;331;996.3198,247.1211;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-4490.121,218.9435;Inherit;False;Constant;_Float12;Float 12;9;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;181;-4342.904,721.6213;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;168;-4165.468,445.9498;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;104;842.3538,649.4347;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-4012.047,482.3582;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;319;-2221.522,-1267.02;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;315;-2220.685,-1370.563;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;1173.872,604.2476;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-4345.02,338.2436;Inherit;False;Constant;_Float11;Float 11;9;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;332;1193.127,370.1244;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;-4314.16,244.6714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;316;-2045.413,-1380.776;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;420;2115.543,-2366.542;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;90;-2205.322,-911.048;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;57;-2220.521,-1077.072;Inherit;False; t = saturate(t)@$float oneMinusT = 1 - t@$return oneMinusT * oneMinusT * oneMinusT * P0 + 3 * oneMinusT * oneMinusT * t * P1 + 3 * oneMinusT * t * t * P2 + t * t * t * P3@;3;False;5;True;P0;FLOAT3;0,0,0;In;;Inherit;False;True;P1;FLOAT3;0,0,0;In;;Inherit;False;True;P2;FLOAT3;0,0,0;In;;Inherit;False;True;P3;FLOAT3;0,0,0;In;;Inherit;False;True;t;FLOAT;0;In;;Inherit;False;BezierPoint;True;False;0;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;108;1373.656,499.0689;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;468;1940.35,-2161.711;Inherit;False;Property;_ToonSpecularSize;ToonSpecularSize;21;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;147;1546.306,-1348.895;Inherit;True;Property;_BumpMap;Normal Map;4;0;Create;False;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;170;-3836.992,354.8355;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;445;2398.75,-2378.358;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;318;-1817.992,-1427.893;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;396;2548.396,-1421.48;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;17;-2019.014,-960.3789;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;314;-1819.104,-1032.745;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;1601.569,226.3687;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;470;2287.747,-2157.103;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;263;1780.634,340.4002;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;457;2509.325,-2156.702;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;91;2146.774,-344.3079;Inherit;False;722.79;380.1452;;7;93;95;97;309;96;310;311;Spherize;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;401;2261.817,-1183.385;Inherit;False;Property;_CellShadingSharpness;Cell Shading Sharpness;20;0;Create;True;0;0;False;0;False;0;0.549;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;444;2606.956,-2405.282;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;313;-1688.907,-1171.942;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;1948.856,230.5498;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;97;2166.403,-274.688;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;422;2276.075,-1998.66;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;2575.678,-1136.087;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;454;2843.597,-1947.281;Inherit;False;2;0;FLOAT;1.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;446;2806.186,-2367.59;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;418;2847.947,-2048.825;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;2264.644,-152.349;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;395;2762.792,-1419.399;Inherit;False;Half Lambert Term;-1;;1;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;2992.637,-1915.142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;414;2824.012,-1197.931;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;412;2818.695,-1288.003;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;451;3149.106,-1978.905;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;437;3195.45,-2176.939;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;309;2376.823,-283.7769;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;405;3032.29,-1364.941;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;145;1549.998,-2079.443;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;327;2453.595,198.873;Inherit;False;742.0867;501.8909;;8;101;322;321;323;326;324;328;329;Truncate On/Off;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;14;1593.96,-1845.794;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;False;0,0,0,0;0.2176454,0.5062257,0.6886792,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;93;2505.843,-279.2339;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;311;2434.161,-96.69257;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;449;3371.883,-2126.637;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;320;587.2473,119.6521;Inherit;False;3;0;FLOAT;-0.05;False;1;FLOAT;0.05;False;2;FLOAT;-0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;433;3226.704,-1292.921;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;429;3560.836,-2130.932;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;432;3376.524,-1323.264;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;305;1556.192,-943.8262;Inherit;False;Property;_EmissionPower;EmissionPower;6;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;469;2159.216,-2073.866;Inherit;False;Property;_ToonSpecularIntensity;ToonSpecularIntensity;22;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;411;3013.426,-1794.989;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;398;2810.666,-1612.98;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;283;1541.503,-1137.791;Inherit;True;Property;_Emission;Emission;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;1886.537,-1947.193;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;310;2610.723,-166.5706;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;321;2674.122,268.2253;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;285;2622.372,-589.8409;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;148;1542.528,-1658.123;Inherit;True;Property;_Metallic;Metallic;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;307;1559.293,-1450.405;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;2657.684,351.8397;Inherit;False;Constant;_Float3;Float 3;18;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;74;542.8458,1365.954;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;286;2826.094,-580.9835;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;284;1533.02,-859.0134;Inherit;True;Property;_Occlusion;Occlusion;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;96;2757.124,-103.1002;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;956.0327,1304.37;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;1874.886,-1058.244;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;3269.206,-1524.711;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;1874.715,-1514.605;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;425;3442.83,-1916.869;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;323;2837.391,373.6088;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;956.3741,1410.45;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;955.6949,1199.737;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;415;3276.44,-1698.977;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;407;3466.974,-1523.809;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;393;2912.629,-1031.606;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;101;3008.688,321.5746;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;287;2988.487,-585.4121;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;10000,10000,10000;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;247;2813.048,-697.2805;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;78;1130.988,1293.014;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;183;1360.202,1038.815;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;291;-1742.422,1122.849;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;-1400.225,1125.582;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DiffuseAndSpecularFromMetallicNode;417;1890.843,-1244.63;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;3;FLOAT3;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;-6924.206,-89.50127;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;380;-6693.557,-107.0323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;3165.155,-1170.506;Inherit;False;Property;_Toon;Toon;18;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;328;2793.188,516.3008;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;-1223.307,1100.681;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;3044.913,-2217.541;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;248;3169.731,-681.7598;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;329;2655.389,503.3012;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;312;2214.465,-635.9981;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;289;-1607.974,1037.959;Inherit;False;Constant;_Vector1;Vector 1;2;0;Create;True;0;0;False;0;False;0,0,-5;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;436;3575.133,-957.3501;Inherit;False;Property;_ToonShading;Toon Shading;19;0;Create;True;0;0;False;0;False;1;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;440;3347.959,-2334.971;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;376;-7084.074,-83.50048;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;324;2501.306,424.3834;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;326;2474.689,532.9998;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;156;3905.885,-1066.196;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Raliv/Penetrator;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;346;0;347;0
WireConnection;227;0;231;0
WireConnection;391;1;337;0
WireConnection;348;0;346;0
WireConnection;228;0;226;0
WireConnection;228;1;227;0
WireConnection;387;0;391;0
WireConnection;383;0;347;0
WireConnection;352;0;348;0
WireConnection;349;0;346;0
WireConnection;390;0;387;0
WireConnection;390;1;388;0
WireConnection;460;0;391;0
WireConnection;389;0;387;0
WireConnection;389;1;197;0
WireConnection;374;0;383;0
WireConnection;342;0;228;0
WireConnection;363;0;349;0
WireConnection;363;1;365;0
WireConnection;459;0;211;0
WireConnection;459;1;460;0
WireConnection;375;0;374;0
WireConnection;375;1;379;0
WireConnection;362;0;352;0
WireConnection;362;1;365;0
WireConnection;353;0;346;0
WireConnection;353;1;360;0
WireConnection;343;0;342;1
WireConnection;159;0;390;0
WireConnection;159;1;389;0
WireConnection;229;0;228;0
WireConnection;350;0;270;0
WireConnection;350;1;362;0
WireConnection;361;0;353;0
WireConnection;340;0;229;0
WireConnection;340;1;341;0
WireConnection;340;2;343;0
WireConnection;163;0;162;0
WireConnection;163;1;159;0
WireConnection;378;0;375;0
WireConnection;213;0;459;0
WireConnection;351;0;363;0
WireConnection;351;1;256;0
WireConnection;192;0;163;0
WireConnection;271;0;185;0
WireConnection;271;1;350;0
WireConnection;271;2;273;0
WireConnection;364;0;361;0
WireConnection;364;1;365;0
WireConnection;384;0;374;0
WireConnection;257;0;185;0
WireConnection;257;1;351;0
WireConnection;381;0;378;0
WireConnection;381;1;365;0
WireConnection;244;0;340;0
WireConnection;241;0;185;0
WireConnection;209;0;208;0
WireConnection;209;1;213;0
WireConnection;272;0;257;0
WireConnection;272;1;271;0
WireConnection;358;0;359;0
WireConnection;358;1;364;0
WireConnection;358;2;185;0
WireConnection;373;0;372;0
WireConnection;373;1;185;0
WireConnection;373;2;381;0
WireConnection;193;0;192;0
WireConnection;245;0;244;0
WireConnection;245;1;185;0
WireConnection;245;2;246;0
WireConnection;385;0;384;0
WireConnection;385;1;365;0
WireConnection;187;0;241;0
WireConnection;236;0;192;0
WireConnection;214;0;209;0
WireConnection;277;0;185;0
WireConnection;357;0;245;0
WireConnection;357;1;358;0
WireConnection;357;2;373;0
WireConnection;371;0;370;0
WireConnection;371;1;385;0
WireConnection;261;0;260;0
WireConnection;261;1;272;0
WireConnection;186;0;193;0
WireConnection;186;1;241;0
WireConnection;186;2;187;0
WireConnection;217;0;236;0
WireConnection;217;1;214;0
WireConnection;461;0;217;0
WireConnection;461;1;236;0
WireConnection;461;2;462;0
WireConnection;467;0;340;0
WireConnection;369;0;261;0
WireConnection;369;1;371;0
WireConnection;262;0;193;0
WireConnection;191;0;236;0
WireConnection;191;1;357;0
WireConnection;191;2;186;0
WireConnection;280;0;277;0
WireConnection;160;0;191;0
WireConnection;276;0;192;0
WireConnection;279;0;262;0
WireConnection;279;1;280;0
WireConnection;279;2;277;0
WireConnection;466;0;461;0
WireConnection;259;0;467;0
WireConnection;259;1;369;0
WireConnection;216;0;466;0
WireConnection;216;1;259;0
WireConnection;216;2;279;0
WireConnection;32;0;160;0
WireConnection;268;0;257;0
WireConnection;275;0;276;0
WireConnection;275;1;185;0
WireConnection;73;0;216;0
WireConnection;59;0;32;0
WireConnection;266;0;265;0
WireConnection;266;1;268;0
WireConnection;292;0;275;0
WireConnection;252;0;160;0
WireConnection;110;0;6;3
WireConnection;61;0;59;0
WireConnection;61;1;62;0
WireConnection;274;1;266;0
WireConnection;274;2;292;0
WireConnection;72;0;59;0
WireConnection;72;1;73;0
WireConnection;267;0;61;0
WireConnection;267;1;274;0
WireConnection;251;0;110;0
WireConnection;63;0;252;0
WireConnection;63;1;72;0
WireConnection;65;0;110;0
WireConnection;65;1;32;0
WireConnection;67;0;58;0
WireConnection;67;1;267;0
WireConnection;67;2;63;0
WireConnection;67;3;252;0
WireConnection;67;4;65;0
WireConnection;269;0;251;0
WireConnection;88;0;67;0
WireConnection;88;1;62;0
WireConnection;88;2;269;0
WireConnection;85;0;88;0
WireConnection;299;0;85;0
WireConnection;298;0;299;0
WireConnection;303;0;299;0
WireConnection;300;0;298;0
WireConnection;297;0;18;0
WireConnection;297;2;300;0
WireConnection;304;0;303;0
WireConnection;301;0;297;0
WireConnection;301;2;304;0
WireConnection;20;0;85;0
WireConnection;21;0;301;0
WireConnection;19;0;20;0
WireConnection;19;1;21;0
WireConnection;38;0;19;0
WireConnection;84;0;38;0
WireConnection;22;0;20;0
WireConnection;22;1;84;0
WireConnection;81;0;22;0
WireConnection;24;0;6;2
WireConnection;24;1;81;0
WireConnection;23;0;6;1
WireConnection;23;1;84;0
WireConnection;165;0;32;0
WireConnection;165;1;6;3
WireConnection;42;0;24;0
WireConnection;42;1;23;0
WireConnection;166;0;165;0
WireConnection;36;0;32;0
WireConnection;36;1;110;0
WireConnection;167;0;166;0
WireConnection;167;2;127;0
WireConnection;330;0;36;0
WireConnection;103;0;42;0
WireConnection;102;0;36;0
WireConnection;102;2;109;0
WireConnection;106;0;42;0
WireConnection;331;0;330;0
WireConnection;331;2;109;0
WireConnection;181;0;6;3
WireConnection;168;0;167;0
WireConnection;104;0;103;0
WireConnection;104;1;100;0
WireConnection;169;0;168;0
WireConnection;169;1;175;0
WireConnection;169;2;181;0
WireConnection;319;0;6;3
WireConnection;319;1;32;0
WireConnection;315;0;73;0
WireConnection;107;0;106;0
WireConnection;107;1;104;0
WireConnection;332;0;331;0
WireConnection;332;1;102;0
WireConnection;172;0;173;0
WireConnection;172;1;137;0
WireConnection;316;0;315;0
WireConnection;316;1;319;0
WireConnection;90;2;251;0
WireConnection;57;0;58;0
WireConnection;57;1;267;0
WireConnection;57;2;63;0
WireConnection;57;3;252;0
WireConnection;57;4;65;0
WireConnection;108;0;107;0
WireConnection;108;1;42;0
WireConnection;108;2;332;0
WireConnection;170;0;171;0
WireConnection;170;1;172;0
WireConnection;170;2;169;0
WireConnection;445;0;420;0
WireConnection;318;0;316;0
WireConnection;318;1;160;0
WireConnection;396;0;147;0
WireConnection;17;0;57;0
WireConnection;17;1;90;0
WireConnection;17;2;269;0
WireConnection;314;0;65;0
WireConnection;178;0;108;0
WireConnection;178;1;170;0
WireConnection;470;0;468;0
WireConnection;263;0;178;0
WireConnection;263;1;42;0
WireConnection;263;2;279;0
WireConnection;457;0;470;0
WireConnection;457;1;470;0
WireConnection;444;0;445;0
WireConnection;444;1;396;0
WireConnection;313;0;318;0
WireConnection;313;1;17;0
WireConnection;313;2;314;0
WireConnection;12;0;313;0
WireConnection;12;1;263;0
WireConnection;97;0;160;0
WireConnection;402;0;401;0
WireConnection;454;1;457;0
WireConnection;446;0;444;0
WireConnection;418;0;446;0
WireConnection;418;1;422;0
WireConnection;95;0;12;0
WireConnection;95;1;97;0
WireConnection;395;3;396;0
WireConnection;456;0;454;0
WireConnection;414;0;402;0
WireConnection;412;0;402;0
WireConnection;451;0;457;0
WireConnection;451;1;456;0
WireConnection;437;0;418;0
WireConnection;309;0;95;0
WireConnection;405;0;395;0
WireConnection;405;3;412;0
WireConnection;405;4;414;0
WireConnection;93;0;309;0
WireConnection;93;1;100;0
WireConnection;311;0;95;0
WireConnection;449;0;437;0
WireConnection;449;1;457;0
WireConnection;449;2;451;0
WireConnection;320;0;36;0
WireConnection;433;0;405;0
WireConnection;429;0;449;0
WireConnection;432;0;433;0
WireConnection;411;0;147;0
WireConnection;146;0;145;0
WireConnection;146;1;14;0
WireConnection;310;0;93;0
WireConnection;310;1;311;0
WireConnection;321;0;320;0
WireConnection;286;0;285;0
WireConnection;96;0;310;0
WireConnection;96;1;97;0
WireConnection;76;0;81;0
WireConnection;76;1;74;2
WireConnection;306;0;283;0
WireConnection;306;1;305;0
WireConnection;399;0;398;0
WireConnection;399;1;432;0
WireConnection;399;2;146;0
WireConnection;308;0;148;4
WireConnection;308;1;307;0
WireConnection;425;0;398;0
WireConnection;425;1;429;0
WireConnection;425;2;469;0
WireConnection;323;0;321;0
WireConnection;323;1;322;0
WireConnection;323;2;159;3
WireConnection;77;0;85;0
WireConnection;77;1;74;3
WireConnection;75;0;84;0
WireConnection;75;1;74;1
WireConnection;415;0;411;0
WireConnection;415;1;146;0
WireConnection;407;0;399;0
WireConnection;407;1;415;0
WireConnection;407;2;425;0
WireConnection;393;0;146;0
WireConnection;393;1;147;0
WireConnection;393;2;306;0
WireConnection;393;3;148;0
WireConnection;393;4;308;0
WireConnection;393;5;284;0
WireConnection;101;0;12;0
WireConnection;101;1;96;0
WireConnection;101;2;323;0
WireConnection;287;0;286;0
WireConnection;78;0;75;0
WireConnection;78;1;76;0
WireConnection;78;2;77;0
WireConnection;183;0;78;0
WireConnection;291;0;236;0
WireConnection;290;0;289;0
WireConnection;290;1;291;1
WireConnection;417;0;145;0
WireConnection;417;1;283;0
WireConnection;377;0;376;0
WireConnection;380;0;377;0
WireConnection;380;1;365;0
WireConnection;328;0;329;0
WireConnection;288;0;18;0
WireConnection;288;1;290;0
WireConnection;438;0;398;2
WireConnection;438;1;418;0
WireConnection;248;0;101;0
WireConnection;248;1;287;0
WireConnection;248;2;247;2
WireConnection;329;0;324;0
WireConnection;329;1;326;1
WireConnection;312;0;313;0
WireConnection;312;1;42;0
WireConnection;436;1;393;0
WireConnection;436;0;407;0
WireConnection;440;0;437;0
WireConnection;376;0;374;0
WireConnection;324;0;214;0
WireConnection;324;1;236;0
WireConnection;156;0;146;0
WireConnection;156;13;436;0
WireConnection;156;11;248;0
WireConnection;156;12;183;0
ASEEND*/
//CHKSM=0D288119EA28BAE08451E8C8F7381462934317C1