// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Until"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_ReflectTex("_ReflectTex", CUBE) = "white" {}
		_MaskTex("MaskTex", 2D) = "white" {}
		[HDR]_FreColor("FreColor", Color) = (0.1733179,0.81782,0.8584906,0)
		_MainColor("Main Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_SpecularColor("Specular Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
		_RefIntensidy("RefIntensidy", Range( 0 , 1)) = 0
		_FreSca("FreSca", Range( 0 , 10)) = 1.058824
		_FrePow("FrePow", Range( 0 , 10)) = 0
		[Toggle(_SOFTTRIGGER_ON)] _SoftTrigger("SoftTrigger", Float) = 0
		_PosIntensidy("PosIntensidy", Range( -0.1 , 0.1)) = 0
		_SoftPow("SoftPow", Range( 0 , 10)) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_Dst("Dst", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_Src("Src", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend [_Src] [_Dst]
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#pragma multi_compile_fwdbase


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_SHADOWS 1
			#pragma shader_feature_local _SOFTTRIGGER_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_SHADOW_COORDS(5)
				float4 ase_lmap : TEXCOORD6;
				float4 ase_sh : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform float _Src;
			uniform float _Dst;
			uniform float _PosIntensidy;
			uniform samplerCUBE _ReflectTex;
			uniform float _RefIntensidy;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float4 _SpecularColor;
			uniform float _Shininess;
			uniform float4 _MainColor;
			uniform float _SoftPow;
			uniform float _FreSca;
			uniform float _FrePow;
			uniform float4 _FreColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				#ifdef DYNAMICLIGHTMAP_ON //dynlm
				o.ase_lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif //dynlm
				#ifdef LIGHTMAP_ON //stalm
				o.ase_lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif //stalm
				float3 ase_worldPos = mul(unity_ObjectToWorld, float4( (v.vertex).xyz, 1 )).xyz;
				#ifndef LIGHTMAP_ON //nstalm
				#if UNITY_SHOULD_SAMPLE_SH //sh
				o.ase_sh.xyz = 0;
				#ifdef VERTEXLIGHT_ON //vl
				o.ase_sh.xyz += Shade4PointLights (
				unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				unity_4LightAtten0, ase_worldPos, ase_worldNormal);
				#endif //vl
				o.ase_sh.xyz = ShadeSHPerVertex (ase_worldNormal, o.ase_sh.xyz);
				#endif //sh
				#endif //nstalm
				
				o.ase_texcoord2.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_sh.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = ( _PosIntensidy * v.ase_normal );
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldReflection = reflect(-ase_worldViewDir, ase_worldNormal);
				float2 uv_MainTex = i.ase_texcoord2.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_MaskTex = i.ase_texcoord2.xyz.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 temp_output_43_0_g10 = _SpecularColor;
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float3 normalizeResult4_g11 = normalize( ( ase_worldViewDir + worldSpaceLightDir ) );
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g10 = float3(0,0,1);
				float3 worldNormal12_g10 = float3(dot(tanToWorld0,tanNormal12_g10), dot(tanToWorld1,tanNormal12_g10), dot(tanToWorld2,tanNormal12_g10));
				float3 normalizeResult64_g10 = normalize( worldNormal12_g10 );
				float dotResult19_g10 = dot( normalizeResult4_g11 , normalizeResult64_g10 );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				UNITY_LIGHT_ATTENUATION(ase_atten, i, WorldPosition)
				float4 temp_output_40_0_g10 = ( ase_lightColor * ase_atten );
				float dotResult14_g10 = dot( normalizeResult64_g10 , worldSpaceLightDir );
				UnityGIInput data34_g10;
				UNITY_INITIALIZE_OUTPUT( UnityGIInput, data34_g10 );
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON) //dylm34_g10
				data34_g10.lightmapUV = i.ase_lmap;
				#endif //dylm34_g10
				#if UNITY_SHOULD_SAMPLE_SH //fsh34_g10
				data34_g10.ambient = i.ase_sh;
				#endif //fsh34_g10
				UnityGI gi34_g10 = UnityGI_Base(data34_g10, 1, normalizeResult64_g10);
				float4 temp_output_42_0_g10 = _MainColor;
				float dotResult26 = dot( ase_worldViewDir , ase_worldNormal );
				#ifdef _SOFTTRIGGER_ON
				float staticSwitch32 = saturate( pow( dotResult26 , _SoftPow ) );
				#else
				float staticSwitch32 = 0.0;
				#endif
				float fresnelNdotV16 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode16 = ( 0.0 + _FreSca * pow( 1.0 - fresnelNdotV16, _FrePow ) );
				
				
				finalColor = ( ( texCUBE( _ReflectTex, ase_worldReflection ) * _RefIntensidy ) + ( tex2D( _MainTex, uv_MainTex ) * tex2D( _MaskTex, uv_MaskTex ) * ( ( float4( (temp_output_43_0_g10).rgb , 0.0 ) * (temp_output_43_0_g10).a * pow( max( dotResult19_g10 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g10 ) + ( ( ( temp_output_40_0_g10 * max( dotResult14_g10 , 0.0 ) ) + float4( gi34_g10.indirect.diffuse , 0.0 ) ) * float4( (temp_output_42_0_g10).rgb , 0.0 ) ) ) * staticSwitch32 ) + ( fresnelNode16 * _FreColor ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;575,57;Float;False;True;-1;2;ASEMaterialInspector;100;5;Until;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;True;_Src;1;True;_Dst;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;350.2,-51.50003;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;377.2045,421.447;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;13;63.20471,541.4468;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;29.65018,462.369;Inherit;False;Property;_PosIntensidy;PosIntensidy;12;0;Create;True;0;0;0;False;0;False;0;-0.029;-0.1;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-146.1001,-22.57951;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldReflectionVector;8;-281.1318,-411.1572;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;7;-4.194063,-418.2505;Inherit;True;Property;_ReflectTex;_ReflectTex;1;0;Create;True;0;0;0;True;0;False;-1;None;None;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;393.5208,-312.6293;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;71.94612,-192.2976;Inherit;False;Property;_RefIntensidy;RefIntensidy;8;0;Create;True;0;0;0;False;0;False;0;0.957;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-78.00266,387.7554;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;19;-348.649,588.5572;Inherit;False;Property;_FreColor;FreColor;3;1;[HDR];Create;True;0;0;0;False;0;False;0.1733179,0.81782,0.8584906,0;0,15.08572,16,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;16;-432.9294,344.9391;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-719.1364,406.7943;Inherit;False;Property;_FrePow;FrePow;10;0;Create;True;0;0;0;False;0;False;0;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;26;-1298.316,122.3473;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;27;-1502.611,12.34263;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;28;-1520.072,199.176;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;21;-706.6003,-438.1527;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-703.1076,-233.8585;Inherit;True;Property;_MaskTex;MaskTex;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;6;-464.2386,57.42075;Inherit;False;Blinn-Phong Light;4;;10;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;COLOR;0;FLOAT;57
Node;AmplifyShaderEditor.SaturateNode;31;-804.7543,158.5077;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-717.6129,328.3021;Inherit;False;Property;_FreSca;FreSca;9;0;Create;True;0;0;0;False;0;False;1.058824;0.45;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;32;-557.0009,189.1213;Inherit;False;Property;_SoftTrigger;SoftTrigger;11;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1229.562,-330.4722;Inherit;False;Property;_Src;Src;15;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1225.229,-244.5724;Inherit;False;Property;_Dst;Dst;14;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;29;-1046.247,50.88057;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1387.705,382.7706;Inherit;False;Property;_SoftPow;SoftPow;13;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
WireConnection;0;0;11;0
WireConnection;0;1;14;0
WireConnection;11;0;9;0
WireConnection;11;1;24;0
WireConnection;11;2;20;0
WireConnection;14;0;15;0
WireConnection;14;1;13;0
WireConnection;24;0;21;0
WireConnection;24;1;22;0
WireConnection;24;2;6;0
WireConnection;24;3;32;0
WireConnection;7;1;8;0
WireConnection;9;0;7;0
WireConnection;9;1;10;0
WireConnection;20;0;16;0
WireConnection;20;1;19;0
WireConnection;16;2;17;0
WireConnection;16;3;18;0
WireConnection;26;0;27;0
WireConnection;26;1;28;0
WireConnection;31;0;29;0
WireConnection;32;0;31;0
WireConnection;29;0;26;0
WireConnection;29;1;30;0
ASEEND*/
//CHKSM=7BA2648AB49349199CFC2458AB398EB3A684150D