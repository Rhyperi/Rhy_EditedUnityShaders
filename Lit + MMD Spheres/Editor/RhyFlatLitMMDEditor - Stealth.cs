using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using publicVariables;

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

    public enum BlendMode
    {
        Opaque,
        Cutout,
        Fade,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
    }
  

    MaterialProperty blendMode;
    MaterialProperty cullMode;
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
    MaterialProperty shadowMask;
    MaterialProperty defaultLightDir;
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
    MaterialProperty stealthMask;
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
    MaterialProperty clampMin;
    MaterialProperty clampMax;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        { //Find Properties
            blendMode = FindProperty("_Mode", props);
            cullMode = FindProperty("_Cull", props);
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
            shadowMask = FindProperty("_ShadowMask", props);
            defaultLightDir = FindProperty("_DefaultLightDir", props);
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
            stealthMask = FindProperty("_StealthMask", props);
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
            clampMin = FindProperty("_ClampMin", props);
            clampMax = FindProperty("_ClampMax", props);
        }
        
        Material material = materialEditor.target as Material;

        { //Shader Properties GUI
            EditorGUIUtility.labelWidth = 0f;
            MyToggleDrawer ToggleDraw = new MyToggleDrawer();

            EditorGUI.BeginChangeCheck();
            {
                EditorGUI.showMixedValue = blendMode.hasMixedValue;
                EditorGUI.showMixedValue = cullMode.hasMixedValue;

                var bMode = (BlendMode)blendMode.floatValue;
                var cMode = (CullMode)cullMode.floatValue;

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
                cMode = (CullMode)EditorGUILayout.Popup("Cull Mode", (int)cMode, Enum.GetNames(typeof(CullMode)));
                if (EditorGUI.EndChangeCheck())
                {
                    materialEditor.RegisterPropertyChangeUndo("Rendering Mode");
                    cullMode.floatValue = (float)cMode;
                }

                EditorGUI.showMixedValue = false;
                GUILayout.Space(4);
                GUILayout.Label("Minimum Light Intensity");
                materialEditor.ShaderProperty(clampMin, "", 2);
                GUILayout.Label("Maximum Light Intensity");
                materialEditor.ShaderProperty(clampMax, "", 2);
                GUILayout.Space(8);
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
                materialEditor.TexturePropertySingleLine(new GUIContent("Stealth Mask", "Stealth Pattern Mask"), stealthMask);
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
                materialEditor.TexturePropertySingleLine(new GUIContent("Shadow Texture"), shadowTex);
                EditorGUI.indentLevel += 2;
                materialEditor.TexturePropertySingleLine(new GUIContent("Shadow Mask"), shadowMask);
                EditorGUI.indentLevel -= 2;
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

                GUILayout.Space(20);
                GUILayout.Label("Version: " + shaderVariables.versionNumber + " - Stealth");
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
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                break;
            case BlendMode.Fade:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                break;
        }
    }
}