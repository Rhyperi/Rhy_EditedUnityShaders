﻿using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class RhyFlatLitMMDEditorWiggle : ShaderGUI
{

    public enum OutlineMode
    {
        None,
        Tinted,
        Colored
    }

    public enum BlendMode
    {
        Opaque,
        Cutout,
        Fade,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
    }

    MaterialProperty blendMode;
    MaterialProperty mainTexture;
    MaterialProperty opacity;
    MaterialProperty color;
    MaterialProperty colorMask;
    MaterialProperty colIntensity;
    MaterialProperty sphereAddTexture;
    MaterialProperty sphereAddIntensity;
    MaterialProperty sphereAddMask;
    MaterialProperty sphereMulTexture;
    MaterialProperty sphereMulIntensity;
    MaterialProperty toonTex;
    MaterialProperty shadowTex;
    MaterialProperty defaultLightDir;
    MaterialProperty emissionMap;
    MaterialProperty emissionColor;
    MaterialProperty emissionMask;
    MaterialProperty emissionIntensity;
    MaterialProperty speedX;
    MaterialProperty speedY;
    MaterialProperty noiseTexture;
    MaterialProperty noiseMask;
    MaterialProperty noiseX;
    MaterialProperty noiseY;
    MaterialProperty noiseZ;
    MaterialProperty speedX2;
    MaterialProperty speedY2;
    MaterialProperty normalMap;
    MaterialProperty alphaCutoff;
    MaterialProperty specularBleed;


    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        { //Find Properties
            blendMode = FindProperty("_Mode", props);
            mainTexture = FindProperty("_MainTex", props);
            opacity = FindProperty("_Opacity", props);
            color = FindProperty("_Color", props);
            colorMask = FindProperty("_ColorMask", props);
            colIntensity = FindProperty("_ColorIntensity", props);
            sphereAddTexture = FindProperty("_SphereAddTex", props);
            sphereAddIntensity = FindProperty("_SphereAddIntensity", props);
            sphereAddMask = FindProperty("_SphereMap", props);
            sphereMulTexture = FindProperty("_SphereMulTex", props);
            sphereMulIntensity = FindProperty("_SphereMulIntensity", props);
            toonTex = FindProperty("_ToonTex", props);
            shadowTex = FindProperty("_ShadowTex", props);
            defaultLightDir = FindProperty("_DefaultLightDir", props);
            emissionMap = FindProperty("_EmissionMap", props);
            emissionColor = FindProperty("_EmissionColor", props);
            emissionMask = FindProperty("_EmissionMask", props);
            emissionIntensity = FindProperty("_EmissionIntensity", props);
            speedX = FindProperty("_SpeedX", props);
            speedY = FindProperty("_SpeedY", props);
            noiseTexture = FindProperty("_NoiseTex", props);
            noiseMask = FindProperty("_NoiseMask", props);
            noiseX = FindProperty("_NoiseX", props);
            noiseY = FindProperty("_NoiseY", props);
            noiseZ = FindProperty("_NoiseZ", props);
            speedX2 = FindProperty("_SpeedX2", props);
            speedY2 = FindProperty("_SpeedY2", props);
            normalMap = FindProperty("_BumpMap", props);
            alphaCutoff = FindProperty("_Cutoff", props);
            specularBleed = FindProperty("_SpecularBleed", props);
        }
        
        Material material = materialEditor.target as Material;

        { //Shader Properties GUI
            EditorGUIUtility.labelWidth = 0f;
            
            EditorGUI.BeginChangeCheck();
            {
                EditorGUI.showMixedValue = blendMode.hasMixedValue;
                var bMode = (BlendMode)blendMode.floatValue;

                EditorGUI.BeginChangeCheck();
                GUILayout.Label("-General Textures-", EditorStyles.boldLabel);
                bMode = (BlendMode)EditorGUILayout.Popup("Rendering Mode", (int)bMode, Enum.GetNames(typeof(BlendMode)));
                if (EditorGUI.EndChangeCheck())
                {
                    materialEditor.RegisterPropertyChangeUndo("Rendering Mode");
                    blendMode.floatValue = (float)bMode;

                    foreach (var obj in blendMode.targets)
                    {
                        SetupMaterialWithBlendMode((Material)obj, (BlendMode)material.GetFloat("_Mode"));
                    }
                }

                EditorGUI.showMixedValue = false;
                materialEditor.TexturePropertySingleLine(new GUIContent("Main Texture", "Main Color Texture"), mainTexture, color);
                EditorGUI.indentLevel += 2;          
                if ((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout)
                    materialEditor.ShaderProperty(alphaCutoff, "Alpha Cutoff", 2);
                if ((BlendMode)material.GetFloat("_Mode") == BlendMode.Transparent)
                    materialEditor.ShaderProperty(opacity, "Opacity", 1);
                materialEditor.ShaderProperty(colIntensity, "Color Intensity", 2);
                materialEditor.TexturePropertySingleLine(new GUIContent("Color Mask", "Masks Color Tinting"), colorMask);
                EditorGUI.indentLevel -= 2;
                GUILayout.Space(6);
                GUILayout.Label("-Sphere Textures-", EditorStyles.boldLabel);
                materialEditor.TexturePropertySingleLine(new GUIContent("Additive Sphere Texture"), sphereAddTexture);
                EditorGUI.indentLevel += 2;
                    materialEditor.TexturePropertySingleLine(new GUIContent("Additive Sphere Mask"), sphereAddMask);
                EditorGUI.indentLevel -= 2;
                    materialEditor.ShaderProperty(sphereAddIntensity, "Intensity", 2);
                materialEditor.ShaderProperty(specularBleed, "Specular Bleed Through", 2);
                materialEditor.TexturePropertySingleLine(new GUIContent("Multiply Sphere Texture"), sphereMulTexture);
                    materialEditor.ShaderProperty(sphereMulIntensity, "Intensity", 2);
                GUILayout.Space(6);
                GUILayout.Label("-Toon Ramp-", EditorStyles.boldLabel);
                materialEditor.TexturePropertySingleLine(new GUIContent("Toon Texture"), toonTex);
                materialEditor.TexturePropertySingleLine(new GUIContent("Shadow Texture"), shadowTex);
                materialEditor.VectorProperty(defaultLightDir, "Default Light Direction");
                GUILayout.Label("-Normal Maps-", EditorStyles.boldLabel);
                materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map", "Normal Map"), normalMap);
                materialEditor.TextureScaleOffsetProperty(normalMap);
                GUILayout.Space(6);
                GUILayout.Label("-Other Effects-", EditorStyles.boldLabel);
                materialEditor.TexturePropertySingleLine(new GUIContent("Emission", "Emission"), emissionMap, emissionColor);
                    materialEditor.ShaderProperty(emissionIntensity, "Intensity", 2);
                EditorGUI.indentLevel += 2;
                    materialEditor.TexturePropertySingleLine(new GUIContent("Emission Mask"), emissionMask);
                    materialEditor.TextureScaleOffsetProperty(emissionMask);
                    materialEditor.ShaderProperty(speedX, new GUIContent("Mask X Scroll Speed"), 0);
                    materialEditor.ShaderProperty(speedY, new GUIContent("Mask Y Scroll Speed"), 0);
                EditorGUI.indentLevel -= 2;
                GUILayout.Space(6);
                materialEditor.TexturePropertySingleLine(new GUIContent("Noise Texture", "Noise Texture"), noiseTexture);              
                materialEditor.TexturePropertySingleLine(new GUIContent("Noise Mask"), noiseMask);
                EditorGUI.indentLevel += 2;
                materialEditor.ShaderProperty(noiseX, new GUIContent("Noise X modifier"), 0);
                materialEditor.ShaderProperty(noiseY, new GUIContent("Noise Y modifier"), 0);
                materialEditor.ShaderProperty(noiseZ, new GUIContent("Noise Z modifier"), 0);
                materialEditor.ShaderProperty(speedX2, new GUIContent("Noise X Scroll Speed"), 0);
                materialEditor.ShaderProperty(speedY2, new GUIContent("Noise Y Scroll Speed"), 0);
                EditorGUI.indentLevel -= 2;
                GUILayout.Space(20);
                GUILayout.Label("Version: 1.8");
                EditorGUI.BeginChangeCheck();
                
                
                EditorGUILayout.Space();      
            }
            EditorGUI.EndChangeCheck();
        }

    }

    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch ((BlendMode)material.GetFloat("_Mode"))
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = -1;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.EnableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendMode.Fade:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.EnableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
        }
    }

    public static void SetupMaterialWithOutlineMode(Material material, OutlineMode outlineMode)
    {
        switch ((OutlineMode)material.GetFloat("_OutlineMode"))
        {
            case OutlineMode.None:
                material.EnableKeyword("NO_OUTLINE");
                material.DisableKeyword("TINTED_OUTLINE");
                material.DisableKeyword("COLORED_OUTLINE");
                break;
            case OutlineMode.Tinted:
                material.DisableKeyword("NO_OUTLINE");
                material.EnableKeyword("TINTED_OUTLINE");
                material.DisableKeyword("COLORED_OUTLINE");
                break;
            case OutlineMode.Colored:
                material.DisableKeyword("NO_OUTLINE");
                material.DisableKeyword("TINTED_OUTLINE");
                material.EnableKeyword("COLORED_OUTLINE");
                break;
            default:
                break;
        }
    }
}