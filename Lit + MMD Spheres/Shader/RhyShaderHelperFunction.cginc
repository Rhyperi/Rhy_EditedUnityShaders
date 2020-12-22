// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

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

struct LightContainer
{
	float3 lightDir;
	float3 lightCol;
	float3 directLit;
	float3 indirectLit;
	float bw_lightDif;
};

struct MatcapContainer
{
	float4 Add;
	float4 Mul;
	float3 Mask;
	float Shadow;
	float2 UV;
};

float2 matcapSample(float3 worldUp, float3 viewDirection, float3 normalDirection)
{
	half3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
	half3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
	half2 matcapUV = half2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection)) * 0.5 + 0.5;
	return matcapUV;				
}

float3 VRViewPosition()
{
	#if defined(USING_STEREO_MATRICES)
		float3 leftEye = unity_StereoWorldSpaceCameraPos[0];
		float3 rightEye = unity_StereoWorldSpaceCameraPos[1];
            
		float3 centerEye = lerp(leftEye, rightEye, 0.5);
    #else
		float3 centerEye = _WorldSpaceCameraPos;
    #endif
    return centerEye;
}

float FadeShadows(float attenuation, float3 worldPosition)
{
    float viewZ = dot(_WorldSpaceCameraPos - worldPosition, UNITY_MATRIX_V[2].xyz);
    float shadowFadeDistance = UnityComputeShadowFadeDistance(worldPosition, viewZ);
    float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
    attenuation = saturate(attenuation + shadowFade);
    return attenuation;
}

half3 GetSHLength()
{
    half3 x, x1;
    x.r = length(unity_SHAr);
    x.g = length(unity_SHAg);
    x.b = length(unity_SHAb);
    x1.r = length(unity_SHBr);
    x1.g = length(unity_SHBg);
    x1.b = length(unity_SHBb);
    return x + x1;
}

float3 ShadeSH9Normal(float3 normalDirection)
{
    return ShadeSH9(half4(normalDirection, 1.0));
}

float4 positionFind (float4 position)
{
	return mul(unity_WorldToObject, position);
}

float3 normalFind (float3 normal)
{
	return mul(unity_WorldToObject, normal);
}

float grayscaleSH9(float3 normalDirection)
{
	return dot(ShadeSH9(half4(normalDirection, 1.0)), grayscale_vector);
}

float4 calculateColor(float4 inLight)
{
	float4 color;
	float3 colorCalculatedForThisFragment = float3(1,1,1);
	color.rgb = colorCalculatedForThisFragment * inLight;
	color.a = 1;
	return color;
}

LightContainer CalculateLight(float4 inLight, fixed4 inColor, float3 inNormal, float inAttenuation, float inMin, float inMax)
{
	LightContainer returnLight;
	float3 lightDirection = normalize(inLight.xyz);	
	float light_Env = float(any(inLight.xyz));
	float4 lightColor = inColor;
	float3 indirectDiffuse = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
	
	if(light_Env != 1)
	{
			lightDirection = normalize(_DefaultLightDir);
			lightColor.rgb = indirectDiffuse;
	}
				
	float bottomIndirectLighting = grayscaleSH9(float3(0.0, -1.0, 0.0));
	float topIndirectLighting = grayscaleSH9(float3(0.0, 1.0, 0.0));
	float colorIndirectLighting = dot(lightDirection, inNormal) * lightColor * inAttenuation + grayscaleSH9(inNormal);
	float3 ShadeSH9Plus = GetSHLength();
	float3 ShadeSH9Minus = ShadeSH9(float4(0, 0, 0, 1));
				
	float bw_lightColor = dot(lightColor, grayscale_vector);
	float bw_bottomIndirectLighting = dot(ShadeSH9Minus, grayscale_vector);
	float bw_topIndirectLighting = dot(ShadeSH9Plus, grayscale_vector);
	float bw_lightDifference = (bw_topIndirectLighting + bw_lightColor) - bw_bottomIndirectLighting;

	lightColor = clamp(lightColor, inMin, inMax);

	float3 indirectLighting = ShadeSH9Minus;
	float3 directLighting = ShadeSH9Plus + lightColor;

	returnLight.lightDir = lightDirection;
	returnLight.lightCol = lightColor;
	returnLight.directLit = directLighting;
	returnLight.indirectLit = indirectLighting;
	returnLight.bw_lightDif = bw_lightDifference;

	return returnLight;
}

MatcapContainer CalculateSphere(float3 inNormal, VertexOutput inI, sampler2D inAdd, sampler2D inMul, sampler2D inMask, float2 inUV, float inBleed, float inSign, float inAttenuation)
{
	MatcapContainer Matcap;
	float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_V, inNormal));
    float3 viewDir = normalize(UnityWorldToViewPos(inI.posWorld));
    float3 viewCross = cross(viewDir, viewNormal);
    viewNormal = float3(-viewCross.y, viewCross.x, 0.0);
				
	float cameraRoll = -atan2(UNITY_MATRIX_I_V[1].x, UNITY_MATRIX_I_V[1].y);
	float sinX = sin(cameraRoll);
	float cosX = cos(cameraRoll);
	float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
	viewNormal.xy = mul(viewNormal, rotationMatrix*inSign);
				
	float specularShadows = ((inAttenuation * .9) + inBleed);
	if(specularShadows > 1)
		specularShadows = 1;
				
	float2 sphereUV = viewNormal.xy * 0.5 + 0.5;
	float3 sphereMap_var = tex2D(inMask, inUV);
	float4 sphereAdd = tex2D(inAdd, sphereUV);
	float4 sphereMul = tex2D(inMul, sphereUV);

	Matcap.Add = sphereAdd;
	Matcap.Mul = sphereMul;
	Matcap.Mask = sphereMap_var;
	Matcap.Shadow = specularShadows;
	Matcap.UV = sphereUV;

	return Matcap;	
}

float4 CalculateColor(sampler2D inTexture, float2 inUV, float4 inColor)
{
	float4 baseColor = tex2D(inTexture, inUV);
	baseColor.rgb = (baseColor.rgb*_Color.rgb);
	return baseColor;
}

float3 CalculateNormal(float2 inUV, sampler2D inNormal, float3x3 inTngentTransform)
{
	float3 _BumpMap_var = UnpackNormal(tex2D(inNormal, inUV));
	float3 normalDirection = normalize(mul(_BumpMap_var.rgb, inTngentTransform));
	return normalDirection;
}
#endif