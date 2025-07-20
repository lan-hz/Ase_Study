// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PosANeg"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_BackTex("_BackTex", 2D) = "white" {}
		_addTex("addTex", 2D) = "white" {}
		_NoiseTex("_NoiseTex", 2D) = "white" {}
		_Paramenter("_Paramenter", Vector) = (0.18,1.08,16.92,0)
		_Back_UV_Speed("Back_UV_Speed", Vector) = (1,1,0,-0.2)
		_Add_UV_Speed("Add_UV_Speed", Vector) = (1,1,0,0.2)
		_Noise_UV_Speed("Noise_UV_Speed", Vector) = (1,1,0.2,0.2)
		[HDR]_MainColor("_MainColor", Color) = (0.3254717,1,0.8367176,1)
		[HDR]_AddColor("_AddColor", Color) = (0.254717,0.254717,0.254717,0)
		_NoiseIntensidy("_NoiseIntensidy", Range( 0 , 1.05)) = 0.5016281
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#if defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_D3D9)
			#define FRONT_FACE_SEMANTIC VFACE
			#define FRONT_FACE_TYPE float
			#else
			#define FRONT_FACE_SEMANTIC SV_IsFrontFace
			#define FRONT_FACE_TYPE bool
			#endif


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _MainColor;
			uniform float3 _Paramenter;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _BackTex;
			uniform float4 _Back_UV_Speed;
			uniform sampler2D _addTex;
			uniform float4 _Add_UV_Speed;
			uniform sampler2D _NoiseTex;
			uniform float4 _Noise_UV_Speed;
			uniform float _NoiseIntensidy;
			uniform float4 _AddColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
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
			
			fixed4 frag (v2f i , FRONT_FACE_TYPE ase_vface : FRONT_FACE_SEMANTIC) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float fresnelNdotV2 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode2 = ( _Paramenter.x + _Paramenter.y * pow( 1.0 - fresnelNdotV2, _Paramenter.z ) );
				float2 uv_MainTex = i.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult23 = (float2(_Back_UV_Speed.z , _Back_UV_Speed.w));
				float4 screenPos = i.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult22 = (float2(_Back_UV_Speed.x , _Back_UV_Speed.y));
				float2 panner24 = ( 1.0 * _Time.y * appendResult23 + ( (ase_screenPosNorm).xy * appendResult22 ));
				float2 appendResult26 = (float2(_Add_UV_Speed.z , _Add_UV_Speed.w));
				float2 appendResult29 = (float2(_Add_UV_Speed.x , _Add_UV_Speed.y));
				float2 panner27 = ( 1.0 * _Time.y * appendResult26 + ( ase_screenPosNorm * float4( appendResult29, 0.0 , 0.0 ) ).xy);
				float2 appendResult33 = (float2(_Noise_UV_Speed.z , _Noise_UV_Speed.w));
				float2 appendResult34 = (float2(_Noise_UV_Speed.x , _Noise_UV_Speed.y));
				float2 panner32 = ( 1.0 * _Time.y * appendResult33 + ( ase_screenPosNorm * float4( appendResult34, 0.0 , 0.0 ) ).xy);
				float4 temp_cast_4 = (tex2D( _NoiseTex, panner32 ).r).xxxx;
				float4 lerpResult37 = lerp( tex2D( _addTex, panner27 ) , temp_cast_4 , _NoiseIntensidy);
				float4 switchResult1 = (((ase_vface>0)?(( ( _MainColor * saturate( fresnelNode2 ) ) + tex2D( _MainTex, uv_MainTex ) )):(( tex2D( _BackTex, panner24 ) + ( lerpResult37 * _AddColor ) ))));
				
				
				finalColor = switchResult1;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18912
0;73.6;1336;998;2659.734;111.2182;1.687913;True;False
Node;AmplifyShaderEditor.Vector4Node;30;-1719.397,687.218;Inherit;False;Property;_Add_UV_Speed;Add_UV_Speed;6;0;Create;True;0;0;0;False;0;False;1,1,0,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;35;-1685.066,1228.105;Inherit;False;Property;_Noise_UV_Speed;Noise_UV_Speed;7;0;Create;True;0;0;0;False;0;False;1,1,0.2,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1342.665,1188.105;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-1376.996,647.218;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;19;-2139.84,-28.44606;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;21;-1512.642,160.354;Inherit;False;Property;_Back_UV_Speed;Back_UV_Speed;5;0;Create;True;0;0;0;False;0;False;1,1,0,-0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1180.196,668.0178;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1193.692,1105.279;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1400.996,861.6179;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-1366.665,1402.505;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;20;-1189.441,-52.44601;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;5;-988.074,-466.9751;Inherit;False;Property;_Paramenter;_Paramenter;4;0;Create;True;0;0;0;False;0;False;0.18,1.08,16.92;-0.22,0.41,3.44;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;32;-1077.065,1336.905;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-1170.241,120.354;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;27;-1111.396,796.0179;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-973.4414,141.1539;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1194.241,334.7539;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;2;-760.074,-453.9751;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-455.2439,1418.476;Inherit;False;Property;_NoiseIntensidy;_NoiseIntensidy;10;0;Create;True;0;0;0;False;0;False;0.5016281;0.5016281;0;1.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-811.8738,1233.651;Inherit;True;Property;_NoiseTex;_NoiseTex;3;0;Create;True;0;0;0;False;0;False;-1;527df8c477f4570419434fcd79c00640;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;36;-719.1157,758.0463;Inherit;True;Property;_addTex;addTex;2;0;Create;True;0;0;0;False;0;False;-1;fbc8536e9d5d1fc42ac2a58389afd895;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;7;-480.074,-432.975;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;24;-904.6411,269.154;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;37;-272.4277,1051.39;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;-97.29516,1319.656;Inherit;False;Property;_AddColor;_AddColor;9;1;[HDR];Create;True;0;0;0;False;0;False;0.254717,0.254717,0.254717,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;8;-585.074,-642.9748;Inherit;False;Property;_MainColor;_MainColor;8;1;[HDR];Create;True;0;0;0;False;0;False;0.3254717,1,0.8367176,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-774.074,-238.975;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;5d82fff9d0aed184187d4489ecbf635e;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;42.46157,878.5399;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-313.074,-480.9751;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;14;-382.8404,355.954;Inherit;True;Property;_BackTex;_BackTex;1;0;Create;True;0;0;0;False;0;False;-1;ebc644d6e8cf3cd468a5a27e3b27b230;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;41;301.1654,529.0638;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-100.2288,-409.1978;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;1;27.726,-54.37497;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;259.2,-142;Float;False;True;-1;2;ASEMaterialInspector;100;1;PosANeg;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;34;0;35;1
WireConnection;34;1;35;2
WireConnection;29;0;30;1
WireConnection;29;1;30;2
WireConnection;28;0;19;0
WireConnection;28;1;29;0
WireConnection;31;0;19;0
WireConnection;31;1;34;0
WireConnection;26;0;30;3
WireConnection;26;1;30;4
WireConnection;33;0;35;3
WireConnection;33;1;35;4
WireConnection;20;0;19;0
WireConnection;32;0;31;0
WireConnection;32;2;33;0
WireConnection;22;0;21;1
WireConnection;22;1;21;2
WireConnection;27;0;28;0
WireConnection;27;2;26;0
WireConnection;25;0;20;0
WireConnection;25;1;22;0
WireConnection;23;0;21;3
WireConnection;23;1;21;4
WireConnection;2;1;5;1
WireConnection;2;2;5;2
WireConnection;2;3;5;3
WireConnection;10;1;32;0
WireConnection;36;1;27;0
WireConnection;7;0;2;0
WireConnection;24;0;25;0
WireConnection;24;2;23;0
WireConnection;37;0;36;0
WireConnection;37;1;10;1
WireConnection;37;2;38;0
WireConnection;39;0;37;0
WireConnection;39;1;40;0
WireConnection;9;0;8;0
WireConnection;9;1;7;0
WireConnection;14;1;24;0
WireConnection;41;0;14;0
WireConnection;41;1;39;0
WireConnection;6;0;9;0
WireConnection;6;1;4;0
WireConnection;1;0;6;0
WireConnection;1;1;41;0
WireConnection;0;0;1;0
ASEEND*/
//CHKSM=2DD1408B11A3D3A09AAE7E41D4B53D39EC4D9436