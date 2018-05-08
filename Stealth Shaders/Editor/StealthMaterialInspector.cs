using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
public class StealthMaterialInspector : MaterialEditor {
	

	//EditorVariables
	static bool customEditor = true;
	static bool vis = false;
	static bool s1= true,s2= true;

	static bool triplanarToggle;


	static string[] options = new string[] {"UV2", "Triplanar"};
    static int optionsindex = 0;

	static string[] options2 = new string[] {"UV1", "Triplanar"};
    static int optionsindex2 = 0;
	Material mat;
	int selected ;

	public override void OnInspectorGUI()
	{
		base.serializedObject.Update();
		var theShader = serializedObject.FindProperty ("m_Shader");

		if (isVisible && !theShader.hasMultipleDifferentValues && theShader.objectReferenceValue != null )
		{

			Shader shader = theShader.objectReferenceValue as Shader;


			mat = target as Material;


			if (mat.GetFloat ("_VisibleEffect") == 1) {
				vis = true;
			} else {
				vis = false;
			}


			//optionsindex = (int) mat.GetFloat ("_TriplanarUV2");
			

		
			mat.globalIlluminationFlags = (MaterialGlobalIlluminationFlags)EditorGUILayout.EnumPopup( "Emission GI", mat.globalIlluminationFlags);

			GUILayout.Space(5);

			//CUSTOM EDITOR SECTIONS
			//customEditor = GUILayout.Toggle (customEditor, "Use custom material editor.");
			customEditor = false;
			RangeProperty ("_Stealth", "Stealth",0,1);
			GUILayout.Space (5);
			FloatProperty ("_StealthScale", "Stealth Scale");
			EditorGUILayout.HelpBox("Increase Stealth Scale if the effect does not cover your mesh completely",MessageType.Info);
			GUILayout.Space (5);

			
			GUILayout.BeginHorizontal ();
			GUILayout.Label("Pattern Mapping: ");
			int selectedoption2 = Mathf.RoundToInt(mat.GetFloat("_PatternTriplanarUV1"));
			optionsindex2 = EditorGUILayout.Popup(selectedoption2, options2);

			mat.SetFloat("_PatternTriplanarUV1", optionsindex2);

			GUILayout.EndHorizontal ();
			GUILayout.BeginHorizontal ();
			GUILayout.Label("Stealth Mapping: ");

			int selectedoption1 = Mathf.RoundToInt(mat.GetFloat("_TriplanarUV2"));
			optionsindex = EditorGUILayout.Popup(selectedoption1, options);

			mat.SetFloat("_TriplanarUV2", optionsindex);

			GUILayout.EndHorizontal ();


			GUILayout.Space (10);
			if (customEditor) {
				GUILayout.BeginHorizontal ();
				Texture coloricon = Resources.Load ("Icons/textures") as Texture;
				GUILayout.Label (coloricon,labelStyle());
				if (foldButton (s1))
					s1 = !s1;
				GUILayout.EndHorizontal ();
				if (s1){
					if(shader.name == "Marc Sureda/Stealth(Metallic Setup)")
						MetallicSection ();
					else
						SpecularSection ();		
				}
				GUILayout.BeginHorizontal ();
				Texture mainfoamicon = Resources.Load ("Icons/stealth") as Texture;
				GUILayout.Label (mainfoamicon,labelStyle());
				if (foldButton (s2))
					s2 = !s2;
				GUILayout.EndHorizontal ();
				if(s2)
					StealthSection ();

			} else {
				//DEFAULT EDITOR
				if (this.PropertiesGUI ())
					this.PropertiesChanged ();
			}
			if( GUILayout.Button( "Open shader code") ) {
				UnityEditorInternal.InternalEditorUtility.OpenFileAtLineExternal( AssetDatabase.GetAssetPath( shader ), 1 );
			}

			GUILayout.Box("Stealth Camouflage shader created by Marc Sureda, 2017");
		}
	}

	GUIStyle labelStyle(){
		GUIStyle label = new GUIStyle ();
		label.fixedHeight = 25;
		label.alignment = TextAnchor.LowerLeft;
		return label;
	}

	GUIStyle headerStyle(){
		GUIStyle header = new GUIStyle ();
		header.alignment = TextAnchor.MiddleLeft;
		header.fontStyle = FontStyle.Bold;
		header.fontSize = 11;
		return header;
	}

	public void SpecularSection(){
		GUILayout.Space (10);
		ColorPickerHDRConfig hdr = new ColorPickerHDRConfig(0,1,0,1);
		MaterialProperty albedo = MaterialEditor.GetMaterialProperty (targets, "_MainTex");
		MaterialProperty ao = MaterialEditor.GetMaterialProperty (targets, "_AmbientOclussion");
		MaterialProperty specular = MaterialEditor.GetMaterialProperty (targets, "_Specular");
		MaterialProperty emissive = MaterialEditor.GetMaterialProperty (targets, "_Emissive");
		MaterialProperty normalbump = MaterialEditor.GetMaterialProperty (targets, "_BumpMap");
		MaterialProperty gloss = MaterialEditor.GetMaterialProperty (targets, "_GlossR");
		GUILayout.TextField ("Albedo", headerStyle ());
		GUILayout.BeginHorizontal ();
		Color color1 = EditorGUILayout.ColorField (GUIContent.none, mat.GetColor ("_Color"), true, false, false, hdr, GUILayout.MaxWidth(50),GUILayout.MinHeight(15));
		mat.SetColor("_Color", color1);
		TextureProperty (albedo, "");
		GUILayout.EndHorizontal ();
		EditorGUILayout.HelpBox("Alpha as opacity map",MessageType.Info);

		GUILayout.TextField ("Specular", headerStyle ());
		GUILayout.BeginHorizontal ();
		Color colorspec = EditorGUILayout.ColorField (GUIContent.none, mat.GetColor ("_SpecularColor"), true, false, false, hdr, GUILayout.MaxWidth(50),GUILayout.MinHeight(15));
		mat.SetColor("_SpecularColor", colorspec);
		TextureProperty (specular, "");
		GUILayout.EndHorizontal ();
		RangeProperty("_SpecularIntensity", "Specular Intensity",0,1);

		GUILayout.TextField ("Emission", headerStyle ());
		GUILayout.BeginHorizontal ();
		Color coloremis = EditorGUILayout.ColorField (GUIContent.none, mat.GetColor ("_EmissiveColor"), true, false, false, hdr, GUILayout.MaxWidth(50),GUILayout.MinHeight(15));
		mat.SetColor("_EmissiveColor", coloremis);
		TextureProperty (emissive, "");
		GUILayout.EndHorizontal ();
		FloatProperty("_PBREmissiveIntensity", "Emissive Intensity");

		GUILayout.TextField ("Gloss (R)", headerStyle ());
		TextureProperty (gloss, "");
		RangeProperty("_GlossIntensity", "Gloss Intensity",0,1);
		GUILayout.TextField ("Normal", headerStyle ());
		TextureProperty (normalbump, "");
		RangeProperty("_NormalIntensity", "Normal Intensity",0,1);
		GUILayout.TextField ("Ambient Oclussion", headerStyle ());
		TextureProperty (ao, "");

	}


	public void MetallicSection(){
		GUILayout.Space (10);
		ColorPickerHDRConfig hdr = new ColorPickerHDRConfig(0,1,0,1);
		MaterialProperty albedo = MaterialEditor.GetMaterialProperty (targets, "_MainTex");
		MaterialProperty ao = MaterialEditor.GetMaterialProperty (targets, "_AmbientOclussion");
		MaterialProperty metallic = MaterialEditor.GetMaterialProperty (targets, "_MetallicR");
		MaterialProperty emissive = MaterialEditor.GetMaterialProperty (targets, "_Emissive");
		MaterialProperty normalbump = MaterialEditor.GetMaterialProperty (targets, "_BumpMap");
		MaterialProperty rough = MaterialEditor.GetMaterialProperty (targets, "_RoughnessR");
		GUILayout.TextField ("Albedo", headerStyle ());
		GUILayout.BeginHorizontal ();
		Color color1 = EditorGUILayout.ColorField (GUIContent.none, mat.GetColor ("_Color"), true, false, false, hdr, GUILayout.MaxWidth(50),GUILayout.MinHeight(15));
		mat.SetColor("_Color", color1);
		TextureProperty (albedo, "");
		GUILayout.EndHorizontal ();
		EditorGUILayout.HelpBox("Alpha as opacity map",MessageType.Info);

		GUILayout.TextField ("Metallic", headerStyle ());
		GUILayout.BeginHorizontal ();
		TextureProperty (metallic, "");
		GUILayout.EndHorizontal ();
		RangeProperty("_MetallicIntensity", "Metallic Intensity",0,1);

		GUILayout.TextField ("Emission", headerStyle ());
		GUILayout.BeginHorizontal ();
		Color coloremis = EditorGUILayout.ColorField (GUIContent.none, mat.GetColor ("_EmissiveColor"), true, false, false, hdr, GUILayout.MaxWidth(50),GUILayout.MinHeight(15));
		mat.SetColor("_EmissiveColor", coloremis);
		TextureProperty (emissive, "");
		GUILayout.EndHorizontal ();
		FloatProperty("_PBREmissiveIntensity", "Emissive Intensity");

		GUILayout.TextField ("Roughness (R)", headerStyle ());
		TextureProperty (rough, "");
		RangeProperty("_RoughnessIntensity", "Roughness Intensity",0,1);
		GUILayout.TextField ("Normal", headerStyle ());
		TextureProperty (normalbump, "");
		RangeProperty("_NormalIntensity", "Normal Intensity",0,1);
		GUILayout.TextField ("Ambient Oclussion", headerStyle ());
		TextureProperty (ao, "");

	}

	public void StealthSection(){
		GUILayout.Space (10);


		string[] options = new string[]
		{
			"Bottom", "Top", 
		};



		selected = EditorGUILayout.Popup ("Start Gradient", Mathf.RoundToInt( mat.GetFloat ("_StartTopBottom")), options); 
		
		mat.SetFloat ("_StartTopBottom", selected);

		GUILayout.Space (15);
		ColorPickerHDRConfig hdr = new ColorPickerHDRConfig(0,1,0,1);
		GUILayout.BeginHorizontal ();
		Color colorpattern = EditorGUILayout.ColorField (GUIContent.none, mat.GetColor ("_PatternColor"), true, false, false, hdr, GUILayout.MaxWidth(50),GUILayout.MinHeight(15));
		mat.SetColor("_PatternColor", colorpattern);
		MaterialProperty pattern = MaterialEditor.GetMaterialProperty (targets, "_Pattern");
		TextureProperty (pattern, "Pattern");
		GUILayout.EndHorizontal ();
		FloatProperty ("_EmissiveIntensity", "Pattern Emissive Intensity");
		FloatProperty ("_PatternSpeed", "Pattern Speed");
		FloatProperty ("_PatternScale", "Pattern Scale");
		GUILayout.Space (15);


		vis = EditorGUILayout.Toggle ("Visible to Player", vis);
		if (vis) {
			mat.SetFloat ("_VisibleEffect", 1);
		} else {
			mat.SetFloat ("_VisibleEffect", 0);
		}
		FloatProperty ("_VisibleEffectIntensity", "Visible Effect Intensity");

		GUILayout.Space (15);
		FloatProperty ("_RefractionIntensity", "Refraction Intensity");
		RangeProperty("_MinVisibility", "Min Visibility",0,1);
	}


	public bool foldButton(bool b){
		string path = "Icons/fold";
		if (b)
			path = "Icons/unfold";
				
		Texture fold = Resources.Load (path) as Texture;

		Color c = GUI.backgroundColor;
		GUI.backgroundColor = Color.clear;
		bool v = GUILayout.Button (fold, GUILayout.MaxWidth(25), GUILayout.MaxHeight(25));
		GUI.backgroundColor = c;
		return v;
	}


}
