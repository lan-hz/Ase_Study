// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FlowMap"
{
	Properties
	{
		_MianTex("_MianTex", 2D) = "white" {}
		_FlowTex("_FlowTex", 2D) = "white" {}
		_SoftDissoluTex("_SoftDissoluTex", 2D) = "white" {}
		_Intensidy("Intensidy", Range( 0 , 1.05)) = 1.05
		_Soft("Soft", Range( 0.5 , 1)) = 1
		[Enum(on,0,off,1)]_TexOrCust("TexOrCust", Float) = 0
		_MaskPower("MaskPower", Range( 0 , 10)) = 3.06084
		_MaskMul("MaskMul", Range( 0 , 10)) = 1.216608
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
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MianTex;
			uniform float4 _MianTex_ST;
			uniform sampler2D _FlowTex;
			uniform float4 _FlowTex_ST;
			uniform float _Intensidy;
			uniform float _TexOrCust;
			uniform float _Soft;
			uniform sampler2D _SoftDissoluTex;
			uniform float _MaskPower;
			uniform float _MaskMul;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
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
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_MianTex = i.ase_texcoord1.xyz.xy * _MianTex_ST.xy + _MianTex_ST.zw;
				float2 uv_FlowTex = i.ase_texcoord1.xyz.xy * _FlowTex_ST.xy + _FlowTex_ST.zw;
				float3 texCoord24 = i.ase_texcoord1.xyz;
				texCoord24.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult26 = lerp( _Intensidy , texCoord24.z , _TexOrCust);
				float4 lerpResult9 = lerp( float4( uv_MianTex, 0.0 , 0.0 ) , tex2D( _FlowTex, uv_FlowTex ) , lerpResult26);
				float4 tex2DNode2 = tex2D( _MianTex, lerpResult9.rg );
				float4 temp_cast_2 = (( 1.0 - _Soft )).xxxx;
				float4 temp_cast_3 = (_Soft).xxxx;
				float4 smoothstepResult20 = smoothstep( temp_cast_2 , temp_cast_3 , ( tex2D( _SoftDissoluTex, lerpResult9.rg ) + 1.0 + ( -2.0 * lerpResult26 ) ));
				float2 texCoord30 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult6 = (float4((( tex2DNode2 * i.ase_color )).rgb , ( tex2DNode2.a * i.ase_color.a * smoothstepResult20 * saturate( ( pow( ( 1.0 - distance( texCoord30 , float2( 0.5,0.5 ) ) ) , _MaskPower ) * _MaskMul ) ) ).r));
				
				
				finalColor = appendResult6;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18912
0;73.6;1339;998;1317.095;-287.0415;1.873814;True;False
Node;AmplifyShaderEditor.RangedFloatNode;25;-858.7641,878.8043;Inherit;False;Property;_TexOrCust;TexOrCust;5;1;[Enum];Create;True;0;2;on;0;off;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-864.3059,569.1931;Inherit;False;Property;_Intensidy;Intensidy;3;0;Create;True;0;0;0;False;0;False;1.05;0.459586;0;1.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-873.6453,685.3392;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;36;-585.9774,1299.067;Inherit;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-614.8488,1123.028;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;26;-542.5226,729.9849;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-505.8473,-222.4371;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-749.697,205.5147;Inherit;True;Property;_FlowTex;_FlowTex;1;0;Create;True;0;0;0;False;0;False;-1;474cc9046408b9e4e96148ebf53c4153;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;31;-217.8369,1141.258;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;33;43.83474,1138.989;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-7.337494,1422.405;Inherit;False;Property;_MaskPower;MaskPower;6;0;Create;True;0;0;0;False;0;False;3.06084;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-58.13956,754.1407;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;9;-237.0995,29.32933;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;202.7869,956.3447;Inherit;False;Property;_Soft;Soft;4;0;Create;True;0;0;0;False;0;False;1;0.4;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;417.9048,1399.335;Inherit;False;Property;_MaskMul;MaskMul;7;0;Create;True;0;0;0;False;0;False;1.216608;1.216608;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-3.218021,910.0566;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-201.5261,370.3999;Inherit;True;Property;_SoftDissoluTex;_SoftDissoluTex;2;0;Create;True;0;0;0;False;0;False;-1;5fca56f74c768414e8f562cb58300c7d;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;34;309.7048,1131.677;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-45.15817,648.5726;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;540.0571,1113.233;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;114.5646,568.0537;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;23;288.3109,799.6472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-4,-235;Inherit;True;Property;_MianTex;_MianTex;0;0;Create;True;0;0;0;False;0;False;-1;91953d1276b7f7e4c95b0765f541f56e;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;4;95.89304,79.99627;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;39;935.3741,1171.371;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;369.7804,-218.8781;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;20;349.2272,477.2155;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;5;536.323,-202.8893;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;741.0532,171.9621;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;775.1605,-180.5663;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1281.305,-50.30431;Float;False;True;-1;2;ASEMaterialInspector;100;1;FlowMap;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;26;0;11;0
WireConnection;26;1;24;3
WireConnection;26;2;25;0
WireConnection;31;0;30;0
WireConnection;31;1;36;0
WireConnection;33;0;31;0
WireConnection;9;0;3;0
WireConnection;9;1;10;0
WireConnection;9;2;26;0
WireConnection;17;0;18;0
WireConnection;17;1;26;0
WireConnection;13;1;9;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;37;0;34;0
WireConnection;37;1;38;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;15;2;17;0
WireConnection;23;0;21;0
WireConnection;2;1;9;0
WireConnection;39;0;37;0
WireConnection;8;0;2;0
WireConnection;8;1;4;0
WireConnection;20;0;15;0
WireConnection;20;1;23;0
WireConnection;20;2;21;0
WireConnection;5;0;8;0
WireConnection;7;0;2;4
WireConnection;7;1;4;4
WireConnection;7;2;20;0
WireConnection;7;3;39;0
WireConnection;6;0;5;0
WireConnection;6;3;7;0
WireConnection;0;0;6;0
ASEEND*/
//CHKSM=F93BC1AA6D59FCD8EC3546B654CEB6BC87E56E49