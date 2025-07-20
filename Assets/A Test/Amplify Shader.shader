// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Amplify Shader"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[NoScaleOffset]_NoiseTex1("扰动贴图", 2D) = "white" {}
		_Float8("Float 8", Range( 0 , 360)) = 208.1
		_Color0("Color 0", Color) = (0,1,0.4948401,1)
		_Intens("Intens", Range( 0 , 1)) = 1

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

			uniform sampler2D _TextureSample0;
			uniform float4 _TextureSample0_ST;
			uniform float4 _Color0;
			uniform sampler2D _NoiseTex1;
			uniform float _Intens;
			uniform float _Float8;

			
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
				float2 uv_TextureSample0 = i.ase_texcoord1.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float2 texCoord21 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult11_g5 = (float2(1.0 , 1.0));
				float temp_output_17_0_g5 = length( ( (texCoord21*2.0 + -1.0) / appendResult11_g5 ) );
				float2 appendResult11_g4 = (float2(0.9 , 0.9));
				float temp_output_17_0_g4 = length( ( (texCoord21*2.0 + -1.0) / appendResult11_g4 ) );
				float temp_output_51_0 = ( saturate( ( ( 1.0 - temp_output_17_0_g5 ) / fwidth( temp_output_17_0_g5 ) ) ) - saturate( ( ( 1.0 - temp_output_17_0_g4 ) / fwidth( temp_output_17_0_g4 ) ) ) );
				float4 temp_cast_0 = (temp_output_51_0).xxxx;
				float2 uv2_TextureSample0 = i.ase_texcoord1.zw * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float cos86 = cos( 1.0 * _Time.y );
				float sin86 = sin( 1.0 * _Time.y );
				float2 rotator86 = mul( uv2_TextureSample0 - float2( 0.5,0.5 ) , float2x2( cos86 , -sin86 , sin86 , cos86 )) + float2( 0.5,0.5 );
				float4 lerpResult95 = lerp( temp_cast_0 , _Color0 , tex2D( _NoiseTex1, rotator86 ).r);
				float4 lerpResult91 = lerp( ( tex2D( _TextureSample0, uv_TextureSample0 ) * temp_output_51_0 ) , ( temp_output_51_0 * lerpResult95 ) , _Intens);
				float2 texCoord100 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_1 = (0.5).xx;
				float2 Cuv103 = ( texCoord100 - temp_cast_1 );
				float2 break109 = Cuv103;
				float2 _Vector0 = float2(1,0);
				clip( _Float8 - ( ( atan2( ( ( break109.x * _Vector0.y ) - ( _Vector0.x * break109.y ) ) , ( ( break109.x * _Vector0.x ) + ( 0.0 * _Vector0.y ) ) ) * ( 180.0 / 3.1416 ) ) + ( step( 0.0 , break109.y ) * 360.0 ) ));
				float4 color160 = IsGammaSpace() ? float4(0,1,0.001402378,1) : float4(0,1,0.0001085432,1);
				float4 top142 = ( saturate( 0.0 ) * color160 );
				
				
				finalColor = ( lerpResult91 + top142 );
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
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;494.2581,-715.8966;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;15;142.2581,-715.8966;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-1.741879,-715.8966;Inherit;False;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;17;-289.7419,-811.8967;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-513.7419,-811.8967;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-177.7419,-539.8966;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;13;638.258,-715.8966;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;11;318.2581,-715.8966;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FWidthOpNode;14;318.2581,-635.8966;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-513.7419,-715.8966;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;873.9433,1325.101;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;102;647.4273,1447.419;Inherit;False;Constant;_Float4;Float 4;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;739.033,1683.711;Inherit;False;103;Cuv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;109;924.226,1702.775;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;116;1736.359,1814.05;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;1589.443,1811.002;Inherit;False;Constant;_Float5;Float 5;2;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;113;1704.272,1566.423;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;110;1439.89,1600.112;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;1167.452,1560.989;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;1141.834,1877.296;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;104;783.0828,1945.232;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;1096.896,2074.871;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;129;1293.202,2112.496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;1123.07,2200.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;1856.993,1679.859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;1566.395,1890.016;Inherit;False;Constant;_Float9;Float 9;3;0;Create;True;0;0;0;False;0;False;3.1416;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;1922.746,1975.787;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;1751.145,2061.587;Inherit;False;Constant;_angle;angle;3;0;Create;True;0;0;0;False;0;False;360;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;2328.872,1776.104;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;974.1221,40.41052;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;711.5017,615.4841;Inherit;False;Constant;_Float3;Float 3;8;0;Create;True;0;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;1132.501,519.521;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;1284.966,285.1419;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;661.9722,431.8127;Inherit;False;Constant;_Float2;Float 2;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;86;756.9156,756.022;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;63;965.7424,744.3877;Inherit;True;Property;_NoiseTex1;扰动贴图;1;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;a00daea6f04af7240916175aff7e6a5d;a00daea6f04af7240916175aff7e6a5d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;96;885.4638,577.8008;Inherit;False;Ellipse;-1;;4;3ba94b7b3cfd5f447befde8107c04d52;0;3;2;FLOAT2;0,0;False;7;FLOAT;0.5;False;9;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;97;864.8362,328.9619;Inherit;True;Ellipse;-1;;5;3ba94b7b3cfd5f447befde8107c04d52;0;3;2;FLOAT2;0,0;False;7;FLOAT;0.5;False;9;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;91;1996.407,441.7297;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;125;2308.142,1504.885;Inherit;False;Property;_Float8;Float 8;2;0;Create;True;0;0;0;False;0;False;208.1;181;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;89;1047.95,1053.747;Inherit;False;Property;_Color0;Color 0;3;0;Create;True;0;0;0;False;0;False;0,1,0.4948401,1;0,1,0.08014178,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;1562.585,536.1184;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;95;1358.283,806.2001;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;94;1655.415,772.0612;Inherit;False;Property;_Intens;Intens;4;0;Create;True;0;0;0;False;0;False;1;0.58;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3060.78,506.1625;Float;False;True;-1;2;ASEMaterialInspector;100;5;Amplify Shader;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;1821.756,1085.201;Inherit;False;142;top;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;124;2636.363,1785.517;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;619.6414,1301.962;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;1117.071,1319.06;Inherit;False;Cuv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;119;1746.7,1950.606;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;520.8477,748.1136;Inherit;False;1;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;532.0601,265.3077;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;682.1915,27.10431;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;3384.126,1823.675;Inherit;False;top;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;3204.193,1938.933;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;160;2875.571,2112.922;Inherit;False;Constant;_Color1;Color 1;5;0;Create;True;0;0;0;False;0;False;0,1,0.001402378,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;162;2989.735,1895.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;164;2160.99,954.2523;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;10;0;11;0
WireConnection;10;1;14;0
WireConnection;15;0;16;0
WireConnection;16;0;17;0
WireConnection;16;1;12;0
WireConnection;17;1;19;0
WireConnection;17;2;18;0
WireConnection;13;0;10;0
WireConnection;11;0;15;0
WireConnection;14;0;15;0
WireConnection;101;0;100;0
WireConnection;101;1;102;0
WireConnection;109;0;107;0
WireConnection;116;0;115;0
WireConnection;116;1;131;0
WireConnection;113;0;110;0
WireConnection;113;1;129;0
WireConnection;110;0;127;0
WireConnection;110;1;111;0
WireConnection;127;0;109;0
WireConnection;127;1;104;2
WireConnection;111;0;104;1
WireConnection;111;1;109;1
WireConnection;128;0;109;0
WireConnection;128;1;104;1
WireConnection;129;0;128;0
WireConnection;129;1;130;0
WireConnection;130;1;104;2
WireConnection;114;0;113;0
WireConnection;114;1;116;0
WireConnection;134;0;119;0
WireConnection;134;1;135;0
WireConnection;138;0;114;0
WireConnection;138;1;134;0
WireConnection;9;1;23;0
WireConnection;51;0;97;0
WireConnection;51;1;96;0
WireConnection;24;0;9;0
WireConnection;24;1;51;0
WireConnection;86;0;60;0
WireConnection;63;1;86;0
WireConnection;96;2;21;0
WireConnection;96;7;49;0
WireConnection;96;9;49;0
WireConnection;97;2;21;0
WireConnection;97;7;48;0
WireConnection;97;9;48;0
WireConnection;91;0;24;0
WireConnection;91;1;93;0
WireConnection;91;2;94;0
WireConnection;93;0;51;0
WireConnection;93;1;95;0
WireConnection;95;0;51;0
WireConnection;95;1;89;0
WireConnection;95;2;63;1
WireConnection;0;0;164;0
WireConnection;124;1;125;0
WireConnection;124;2;138;0
WireConnection;103;0;101;0
WireConnection;119;1;109;1
WireConnection;142;0;161;0
WireConnection;161;0;162;0
WireConnection;161;1;160;0
WireConnection;162;0;124;0
WireConnection;164;0;91;0
WireConnection;164;1;157;0
ASEEND*/
//CHKSM=1EFE4D373255B9ED93558AFF8A163786CF3D86E8