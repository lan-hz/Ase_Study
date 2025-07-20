// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VertOffset"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_SubColor("_SubColor", Color) = (0.03301889,0.5069543,1,0)
		[HDR]_MainColor("_MainColor", Color) = (2,2,2,1)
		_NoiseTex("_NoiseTex", 2D) = "white" {}
		_Blur("Blur", 2D) = "white" {}
		_XSpeed("_XSpeed", Float) = 0
		_YSpeed("_YSpeed", Float) = 1
		_BlurXSpeed("BlurXSpeed", Float) = 0
		_BlurYSpeed("BlurYSpeed", Float) = 1
		_Height("_Height", Float) = -0.8
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
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_VERT_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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

			uniform sampler2D _NoiseTex;
			uniform float _XSpeed;
			uniform float _YSpeed;
			uniform float4 _NoiseTex_ST;
			uniform sampler2D _Blur;
			uniform float _BlurXSpeed;
			uniform float _BlurYSpeed;
			uniform float4 _Blur_ST;
			uniform float _Height;
			uniform float4 _SubColor;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 appendResult15 = (float2(_XSpeed , _YSpeed));
				float2 uv2_NoiseTex = v.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner14 = ( 1.0 * _Time.y * appendResult15 + uv2_NoiseTex);
				float2 appendResult23 = (float2(_BlurXSpeed , _BlurYSpeed));
				float2 uv2_Blur = v.ase_texcoord1.xy * _Blur_ST.xy + _Blur_ST.zw;
				float2 panner24 = ( _SinTime.w * appendResult23 + uv2_Blur);
				float3 appendResult31 = (float3(0.0 , 0.0 , ( v.color.a * ( ( tex2Dlod( _NoiseTex, float4( panner14, 0, 0.0) ).r * tex2Dlod( _Blur, float4( panner24, 0, 0.0) ).r ) + _Height ) )));
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = appendResult31;
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
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult4 = lerp( _SubColor , ( tex2DNode1 * _MainColor ) , tex2DNode1.r);
				float4 appendResult10 = (float4((lerpResult4).rgb , i.ase_color.a));
				
				
				finalColor = appendResult10;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18912
0;73.6;1539;998;1222.286;657.7077;1.876145;True;False
Node;AmplifyShaderEditor.RangedFloatNode;17;-670.0472,518.2012;Inherit;False;Property;_YSpeed;_YSpeed;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-658.3403,419.5268;Inherit;False;Property;_XSpeed;_XSpeed;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-767.4906,826.1226;Inherit;False;Property;_BlurXSpeed;BlurXSpeed;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-779.1975,924.7972;Inherit;False;Property;_BlurYSpeed;BlurYSpeed;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-581.8493,854.5542;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-682.1961,704.0339;Inherit;False;1;19;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-573.0459,297.4383;Inherit;False;1;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;26;-607.7202,1012.446;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;15;-472.6992,447.9583;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;14;-240.2296,387.7502;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;24;-349.3794,794.3459;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;12;24.01626,237.2304;Inherit;True;Property;_NoiseTex;_NoiseTex;3;0;Create;True;0;0;0;False;0;False;-1;e20b000ff1a30404abe212baefb983e2;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-131.0217,692.5621;Inherit;True;Property;_Blur;Blur;4;0;Create;True;0;0;0;False;0;False;-1;858cace892bebf447a6cdbdc1c8112c3;858cace892bebf447a6cdbdc1c8112c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-379.5,-363;Inherit;False;Property;_MainColor;_MainColor;2;1;[HDR];Create;True;0;0;0;False;0;False;2,2,2,1;2,2,2,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-395.5,-567;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;d9d1b788ffc4a3e43b86aac8c2e49d37;d9d1b788ffc4a3e43b86aac8c2e49d37;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-110.5,-346;Inherit;False;Property;_SubColor;_SubColor;1;0;Create;True;0;0;0;False;0;False;0.03301889,0.5069543,1,0;0.03301889,0.5069543,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;10.5,-602;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;366.1399,509.2409;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;581.1026,718.9901;Inherit;False;Property;_Height;_Height;9;0;Create;True;0;0;0;False;0;False;-0.8;-0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;4;247.5,-480;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;777.2729,487.3059;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;9;-52.48104,-31.86477;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;11;376.9523,-602.3007;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;765.6171,64.85652;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;627.8187,-635.7493;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;852.7301,-291.8594;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;803.6083,-531.4557;Float;False;True;-1;2;ASEMaterialInspector;100;1;VertOffset;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;15;0;16;0
WireConnection;15;1;17;0
WireConnection;14;0;13;0
WireConnection;14;2;15;0
WireConnection;24;0;25;0
WireConnection;24;2;23;0
WireConnection;24;1;26;4
WireConnection;12;1;14;0
WireConnection;19;1;24;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;18;0;12;1
WireConnection;18;1;19;1
WireConnection;4;0;6;0
WireConnection;4;1;3;0
WireConnection;4;2;1;1
WireConnection;27;0;18;0
WireConnection;27;1;28;0
WireConnection;11;0;4;0
WireConnection;29;0;9;4
WireConnection;29;1;27;0
WireConnection;10;0;11;0
WireConnection;10;3;9;4
WireConnection;31;2;29;0
WireConnection;0;0;10;0
WireConnection;0;1;31;0
ASEEND*/
//CHKSM=A8C2BB1C78BF7AA848E83684731A0E56896080CB