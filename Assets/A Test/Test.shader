// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Test"
{
	Properties
	{
		[HDR]_MainColor("主颜色", Color) = (0,0,0,0)
		[HDR]_NoiseColor("NoiseColor", Color) = (1,1,1,1)
		_Angle("角度(%)", Range( 0 , 100)) = 0
		_Ply("环宽度", Range( 0 , 50)) = 3.23
		_Speed("扰动速度", Range( 0 , 3)) = 0
		_Intens("底环透明度", Range( 0 , 1)) = 0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform half4 _MainColor;
			uniform half _Angle;
			uniform half _Ply;
			uniform half _Intens;
			uniform half4 _NoiseColor;
			uniform sampler2D _TextureSample0;
			uniform half _Speed;
			uniform half4 _TextureSample0_ST;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord1.zw = v.ase_texcoord1.xy;
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
				half2 texCoord34 = i.ase_texcoord1.xy * float2( 100,100 ) + float2( 0,0 );
				half temp_output_41_0 = step( (100.0 + (_Angle - 0.0) * (0.0 - 100.0) / (100.0 - 0.0)) , texCoord34.x );
				half temp_output_46_0 = step( texCoord34.y , _Ply );
				half temp_output_97_0 = ( ( 1.0 - temp_output_41_0 ) * temp_output_46_0 );
				half4 temp_cast_0 = (( temp_output_97_0 * _Intens )).xxxx;
				half2 temp_cast_1 = (_Speed).xx;
				half2 uv2_TextureSample0 = i.ase_texcoord1.zw * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				half2 temp_cast_2 = (uv2_TextureSample0.x).xx;
				half2 panner55 = ( 1.0 * _Time.y * temp_cast_1 + temp_cast_2);
				half4 lerpResult101 = lerp( temp_cast_0 , _NoiseColor , tex2D( _TextureSample0, panner55 ).r);
				
				
				finalColor = ( ( _MainColor * temp_output_41_0 * temp_output_46_0 ) + ( temp_output_97_0 * lerpResult101 ) );
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
Node;AmplifyShaderEditor.CommentaryNode;108;-630.345,68.18164;Inherit;False;2249.935;1061.293;Comment;20;51;50;59;56;55;62;101;47;46;86;106;103;105;97;31;88;34;41;112;113;充电;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2022.127,825.9448;Half;False;True;-1;2;ASEMaterialInspector;100;5;Test;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-421.5203,207.8253;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;100,100;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;88;1390.79,702.1718;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;431.1549,465.8898;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;770.6106,625.1993;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;86;241.9328,283.4744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;46;-189.7638,521.3973;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;62;407.8051,788.1509;Inherit;False;Property;_NoiseColor;NoiseColor;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.2704979,0.921582,0.4019779,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;55;-160.6135,913.7305;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;680.1196,257.4924;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;51;403.0306,111.8442;Inherit;False;Property;_MainColor;主颜色;0;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;0.2687045,0.9215686,0.1607843,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-473.0236,1031.358;Half;False;Property;_Speed;扰动速度;4;0;Create;False;0;0;0;False;0;False;0;0.5;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-520.9449,484.2339;Half;False;Property;_Ply;环宽度;3;0;Create;False;0;0;0;False;0;False;3.23;5;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;397.2497,699.2109;Half;False;Property;_Intens;底环透明度;5;0;Create;False;0;0;0;False;0;False;0;0.64;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-457.4073,112.6673;Half;False;Property;_Angle;角度(%);2;0;Create;False;1;充电;0;0;False;0;False;0;54.6;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;1109.275,653.6201;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;101;885.9282,815.039;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;112;155.0776,913.8994;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;0;False;0;False;-1;None;482ce6055bd4dbb4ab6be41eec2d2250;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;56;-447.3127,903.441;Inherit;False;1;112;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.1,0;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;113;-138.4601,139.0247;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;100;False;3;FLOAT;100;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;41;29.6617,244.9041;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;0;0;88;0
WireConnection;88;0;50;0
WireConnection;88;1;103;0
WireConnection;97;0;86;0
WireConnection;97;1;46;0
WireConnection;105;0;97;0
WireConnection;105;1;106;0
WireConnection;86;0;41;0
WireConnection;46;0;34;2
WireConnection;46;1;47;0
WireConnection;55;0;56;1
WireConnection;55;2;59;0
WireConnection;50;0;51;0
WireConnection;50;1;41;0
WireConnection;50;2;46;0
WireConnection;103;0;97;0
WireConnection;103;1;101;0
WireConnection;101;0;105;0
WireConnection;101;1;62;0
WireConnection;101;2;112;1
WireConnection;112;1;55;0
WireConnection;113;0;31;0
WireConnection;41;0;113;0
WireConnection;41;1;34;1
ASEEND*/
//CHKSM=5E00ED76CCFF2528BD5FF65FA808EB73A353EDAE