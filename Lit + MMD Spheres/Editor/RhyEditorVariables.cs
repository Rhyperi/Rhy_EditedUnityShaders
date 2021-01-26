using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace publicVariables
{
    public class shaderVariables
    {
        public enum BlendMode
        {
            Opaque,
            Cutout,
            Fade,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
            Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
        }

        //Editor Variables
        public static string versionNumber = "2.6 - Lighting Fix";
    }
}