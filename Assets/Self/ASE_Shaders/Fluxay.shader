// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fluxay"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_AddTex("_AddTex", 2D) = "white" {}
		_NoiseTex("_NoiseTex", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity", Range( 0 , 1)) = 0.2341889
		_NoiseSped("NoiseSped", Vector) = (0,2,0,0)
		[HDR]_MainColor("_MainColor", Color) = (2,2,2,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _AddTex;
			uniform float4 _AddTex_ST;
			uniform sampler2D _NoiseTex;
			uniform float2 _NoiseSped;
			uniform float4 _NoiseTex_ST;
			uniform float _NoiseIntensity;
			uniform float4 _MainColor;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode7 = tex2D( _MainTex, uv_MainTex );
				float2 appendResult42 = (float2(0.0 , 1.0));
				float4 _Vector0 = float4(0,1,-1,1);
				float2 temp_cast_0 = (_Vector0.x).xx;
				float2 temp_cast_1 = (_Vector0.y).xx;
				float2 temp_cast_2 = (_Vector0.z).xx;
				float2 temp_cast_3 = (_Vector0.w).xx;
				float2 temp_output_44_0 = (temp_cast_2 + (frac( ( _Time.y * appendResult42 ) ) - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0));
				float2 temp_cast_4 = (_Vector0.x).xx;
				float2 temp_cast_5 = (_Vector0.y).xx;
				float2 temp_cast_6 = (_Vector0.z).xx;
				float2 temp_cast_7 = (_Vector0.w).xx;
				float2 ifLocalVar33 = 0;
				if( fmod( _Time.y , ( ( 1.0 / 1.0 ) + 3.0 ) ) >= 3.0 )
				ifLocalVar33 = temp_output_44_0;
				else
				ifLocalVar33 = float2( -1,-1 );
				float2 uv_AddTex = IN.texcoord.xy * _AddTex_ST.xy + _AddTex_ST.zw;
				float2 uv_NoiseTex = IN.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner19 = ( 1.0 * _Time.y * _NoiseSped + uv_NoiseTex);
				float2 temp_cast_8 = (tex2D( _NoiseTex, panner19 ).r).xx;
				float2 lerpResult17 = lerp( ( ifLocalVar33 + uv_AddTex ) , temp_cast_8 , _NoiseIntensity);
				
				fixed4 c = ( ( tex2DNode7 + ( tex2DNode7.a * tex2D( _AddTex, lerpResult17 ) * _MainColor ) ) * IN.color );
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18912
0;73.6;1539;998;1816.658;1060.328;2.176795;True;False
Node;AmplifyShaderEditor.RangedFloatNode;36;-1178.15,-288.4514;Inherit;False;Constant;_ySpeed;ySpeed;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-891.3199,-233.8844;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1077.043,-610.5525;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;40;-848.0809,-359.6007;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-635.1621,-259.3814;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;37;-745.8905,-602.7908;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-796.3396,-454.0308;Inherit;False;Constant;_dis;dis;6;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-489.7645,-622.1944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;45;-458.2764,-237.0714;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0,1,-1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;43;-429.5923,-311.9691;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;46;-92.88589,-151.0189;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;-1,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TFHCRemapNode;44;-262.2678,-297.6269;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;0,0;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FmodOpNode;39;-294.4357,-597.6168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;20;-540.3339,660.6075;Inherit;False;Property;_NoiseSped;NoiseSped;4;0;Create;True;0;0;0;False;0;False;0,2;0,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-654.8312,410.8388;Inherit;False;0;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-423.8453,113.1792;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;19;-207.0083,485.8624;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ConditionalIfNode;33;97.4708,-371.1109;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;12;-27.84272,323.9049;Inherit;True;Property;_NoiseTex;_NoiseTex;1;0;Create;True;0;0;0;False;0;False;-1;5fca56f74c768414e8f562cb58300c7d;5fca56f74c768414e8f562cb58300c7d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;334.2427,-163.336;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;14;352.7923,619.4624;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;3;0;Create;True;0;0;0;False;0;False;0.2341889;0.1219599;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;4;599.9847,-292.6448;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;17;408.9922,164.2623;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;22;1032.966,280.0994;Inherit;False;Property;_MainColor;_MainColor;5;1;[HDR];Create;True;0;0;0;False;0;False;2,2,2,0;2,2,2,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;734.8999,-299.7999;Inherit;True;Property;_;_;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;712.0549,67.5792;Inherit;True;Property;_AddTex;_AddTex;0;0;Create;True;0;0;0;False;0;False;-1;1c26a195cce0a834b9cd53b3ce8af3d0;1c26a195cce0a834b9cd53b3ce8af3d0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;1183.066,-48.60057;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;25;1689.332,44.59225;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;23;1430.025,-337.2316;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;9;-137.8453,119.6793;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;11;-368.2155,274.092;Inherit;False;Property;_AddTex_Speed;AddTex_Speed;2;0;Create;True;0;0;0;False;0;False;0,1;0,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;1891.953,-91.8676;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;32;-430.0062,-848.7603;Inherit;False; ;1;Create;2;True;In0;FLOAT;0;In;;Inherit;False;True;In1;FLOAT;0;In;;Inherit;False;Diy;True;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;26;2232.769,-274.3517;Float;False;True;-1;2;ASEMaterialInspector;0;6;Fluxay;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;42;1;36;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;37;0;35;0
WireConnection;37;1;36;0
WireConnection;38;0;37;0
WireConnection;38;1;34;0
WireConnection;43;0;41;0
WireConnection;44;0;43;0
WireConnection;44;1;45;1
WireConnection;44;2;45;2
WireConnection;44;3;45;3
WireConnection;44;4;45;4
WireConnection;39;0;40;0
WireConnection;39;1;38;0
WireConnection;19;0;18;0
WireConnection;19;2;20;0
WireConnection;33;0;39;0
WireConnection;33;1;34;0
WireConnection;33;2;44;0
WireConnection;33;3;44;0
WireConnection;33;4;46;0
WireConnection;12;1;19;0
WireConnection;47;0;33;0
WireConnection;47;1;10;0
WireConnection;17;0;47;0
WireConnection;17;1;12;1
WireConnection;17;2;14;0
WireConnection;7;0;4;0
WireConnection;8;1;17;0
WireConnection;21;0;7;4
WireConnection;21;1;8;0
WireConnection;21;2;22;0
WireConnection;23;0;7;0
WireConnection;23;1;21;0
WireConnection;9;0;10;0
WireConnection;9;2;11;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;26;0;24;0
ASEEND*/
//CHKSM=724F769941F547C93ADA3A7DB60517D7F19AAB2B