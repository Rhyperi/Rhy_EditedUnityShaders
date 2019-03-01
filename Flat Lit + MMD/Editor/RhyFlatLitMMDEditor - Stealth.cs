﻿using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class RhyFlatLitMMDEditorStealth : ShaderGUI
{

    public class MyToggleDrawer : MaterialPropertyDrawer
    {
        // Draw the property inside the given rect
        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor editor)
        {
            // Setup
            bool value = (prop.floatValue != 0.0f);

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            // Show the toggle control
            value = EditorGUILayout.Toggle(label, value);

            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                // Set the new value if it has changed
                prop.floatValue = value ? 1.0f : 0.0f;
            }
        }
    }

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
    MaterialProperty color;
    MaterialProperty colorMask;
    MaterialProperty colIntensity;
    MaterialProperty sphereAddTexture;
    MaterialProperty sphereAddIntensity;
    MaterialProperty sphereAddMask;
    MaterialProperty sphereMulTexture;
    MaterialProperty sphereMulIntensity;
    MaterialProperty toonTex;
    MaterialProperty defaultLightDir;
    MaterialProperty outlineMode;
    MaterialProperty outlineWidth;
    MaterialProperty outlineColor;
    MaterialProperty emissionMap;
    MaterialProperty emissionColor;
    MaterialProperty emissionMask;
    MaterialProperty emissionIntensity;
    MaterialProperty speedX;
    MaterialProperty speedY;
    MaterialProperty normalMap;
    MaterialProperty alphaCutoff;
    MaterialProperty stealth;
    MaterialProperty stealthScale;
    MaterialProperty pattern;
    MaterialProperty patternColor;
    MaterialProperty patternSpeed;
    MaterialProperty patternScale;
    MaterialProperty topBottom;
    MaterialProperty visibleEffect;
    MaterialProperty visibleEffectIntensity;
    MaterialProperty minVisibility;
    MaterialProperty refreactionIntensity;
    MaterialProperty triplanarUV2;
    MaterialProperty patternTriplanarUV2;
    MaterialProperty refractionAndPattern;


    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        { //Find Properties
            blendMode = FindProperty("_Mode", props);
            mainTexture = FindProperty("_MainTex", props);
            color = FindProperty("_Color", props);
            colorMask = FindProperty("_ColorMask", props);
            colIntensity = FindProperty("_ColorIntensity", props);
            sphereAddTexture = FindProperty("_SphereAddTex", props);
            sphereAddIntensity = FindProperty("_SphereAddIntensity", props);
            sphereAddMask = FindProperty("_SphereMap", props);
            sphereMulTexture = FindProperty("_SphereMulTex", props);
            sphereMulIntensity = FindProperty("_SphereMulIntensity", props);
            toonTex = FindProperty("_ToonTex", props);
            defaultLightDir = FindProperty("_DefaultLightDir", props);
            outlineMode = FindProperty("_OutlineMode", props);
            outlineWidth = FindProperty("_outline_width", props);
            outlineColor = FindProperty("_outline_color", props);
            emissionMap = FindProperty("_EmissionMap", props);
            emissionColor = FindProperty("_EmissionColor", props);
            emissionMask = FindProperty("_EmissionMask", props);
            emissionIntensity = FindProperty("_EmissiveIntensity", props);
            speedX = FindProperty("_SpeedX", props);
            speedY = FindProperty("_SpeedY", props);
            normalMap = FindProperty("_BumpMap", props);
            alphaCutoff = FindProperty("_Cutoff", props);
            stealth = FindProperty("_Stealth", props);
            stealthScale = FindProperty("_StealthScale", props);
            pattern = FindProperty("_Pattern", props);
            patternColor = FindProperty("_PatternColor", props);
            patternSpeed = FindProperty("_PatternSpeed", props);
            patternScale = FindProperty("_PatternScale", props);
            topBottom = FindProperty("_StartTopBottom", props);
            visibleEffect = FindProperty("_VisibleEffect", props);
            visibleEffectIntensity = FindProperty("_VisibleEffectIntensity", props);
            minVisibility = FindProperty("_MinVisibility", props);
            refreactionIntensity = FindProperty("_RefractionIntensity", props);
            triplanarUV2 = FindProperty("_TriplanarUV2", props);
            patternTriplanarUV2 = FindProperty("_PatternTriplanarUV1", props);
            refractionAndPattern = FindProperty("_RefractionAndPattern", props);
        }
        
        Material material = materialEditor.target as Material;

        { //Shader Properties GUI
            EditorGUIUtility.labelWidth = 0f;
            MyToggleDrawer ToggleDraw = new MyToggleDrawer();

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
                materialEditor.ShaderProperty(colIntensity, "Color Intensity", 2);
                materialEditor.TexturePropertySingleLine(new GUIContent("Color Mask", "Masks Color Tinting"), colorMask);
                EditorGUI.indentLevel -= 2;
                GUILayout.Space(6);

                GUILayout.Label("-Stealth Effects-", EditorStyles.boldLabel);
                materialEditor.ShaderProperty(stealth, new GUIContent("Stealth Effect"), 0);
                materialEditor.ShaderProperty(stealthScale, new GUIContent("Stealth Scale"), 1);
                ToggleDraw.OnGUI(new Rect(0, 0, 100, 20), triplanarUV2, "Use UV2 for Stealth?", materialEditor);
                ToggleDraw.OnGUI(new Rect(0, 0, 100, 20), refractionAndPattern, "Use Pattern?", materialEditor);
                GUILayout.Space(3);
                materialEditor.TexturePropertySingleLine(new GUIContent("Stealth Pattern", "Stealth Pattern"), pattern, patternColor);
                EditorGUI.indentLevel += 2;
                materialEditor.ShaderProperty(patternSpeed, new GUIContent("Pattern Scroll Speed"), 0);
                materialEditor.ShaderProperty(patternScale, new GUIContent("Pattern Scale"), 1);
                materialEditor.ShaderProperty(refreactionIntensity, new GUIContent("Pattern Refreaction Intensity"), 0);
                ToggleDraw.OnGUI(new Rect(0, 0, 100, 20), patternTriplanarUV2, "Use UV2 for Pattern?", materialEditor);
                EditorGUI.indentLevel -= 2;
                GUILayout.Space(3);
                ToggleDraw.OnGUI(new Rect(0, 0, 100, 20), topBottom, "Scroll From Top?", materialEditor);
                ToggleDraw.OnGUI(new Rect(0, 0, 100, 20), visibleEffect, "Have Visible Effect?", materialEditor);
                EditorGUI.indentLevel += 2;
                materialEditor.ShaderProperty(visibleEffectIntensity, new GUIContent("Visible Effect Intensity"), 0);
                materialEditor.ShaderProperty(minVisibility, new GUIContent("Minimum Visibility"), 0);
                EditorGUI.indentLevel -= 2;
                GUILayout.Space(3);

                GUILayout.Space(6);
                GUILayout.Label("-Sphere Textures-", EditorStyles.boldLabel);
                materialEditor.TexturePropertySingleLine(new GUIContent("Additive Sphere Texture"), sphereAddTexture);
                EditorGUI.indentLevel += 2;
                    materialEditor.TexturePropertySingleLine(new GUIContent("Additive Sphere Mask"), sphereAddMask);
                EditorGUI.indentLevel -= 2;
                    materialEditor.ShaderProperty(sphereAddIntensity, "Intensity", 2);
                materialEditor.TexturePropertySingleLine(new GUIContent("Multiply Sphere Texture"), sphereMulTexture);
                    materialEditor.ShaderProperty(sphereMulIntensity, "Intensity", 2);
                GUILayout.Space(6);

                GUILayout.Label("-Toon Ramp-", EditorStyles.boldLabel);
                materialEditor.TexturePropertySingleLine(new GUIContent("Toon Texture"), toonTex);
                materialEditor.VectorProperty(defaultLightDir, "Default Light Direction");
                GUILayout.Space(6);

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
                EditorGUI.BeginChangeCheck();
                
                
                EditorGUILayout.Space();

                var oMode = (OutlineMode)outlineMode.floatValue;

                EditorGUI.BeginChangeCheck();
                oMode = (OutlineMode)EditorGUILayout.Popup("Outline Mode", (int)oMode, Enum.GetNames(typeof(OutlineMode)));
                
                if (EditorGUI.EndChangeCheck())
                {
                    materialEditor.RegisterPropertyChangeUndo("Outline Mode");
                    outlineMode.floatValue = (float)oMode;

                    foreach (var obj in outlineMode.targets)
                    {
                        SetupMaterialWithOutlineMode((Material)obj, (OutlineMode)material.GetFloat("_OutlineMode"));
                    }

                }
                switch (oMode)
                {
                    case OutlineMode.Tinted:
                    case OutlineMode.Colored:
                        materialEditor.ShaderProperty(outlineColor, "Color", 2);
                        materialEditor.ShaderProperty(outlineWidth, new GUIContent("Width", "Outline Width in cm"), 2);
                        break;
                    case OutlineMode.None:
                    default:
                        break;
                }                
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