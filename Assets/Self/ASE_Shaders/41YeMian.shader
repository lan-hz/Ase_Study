// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "41YeMian"
{
	Properties
	{
		Parallax("视差折射率", Range( 0 , 3)) = 0.2230301
		_DesSpeed("A_xy密度_zw速度", Vector) = (0,0,0,0)
		_DesSpeed1("B_xy密度_zw速度", Vector) = (0,0,0,0)
		_DesSpeed2("液面纹理_xy密度_zw速度", Vector) = (0,0,0,0)
		_DesSpeed3("液面裁剪", Vector) = (0,0,0,1)
		MainTex("视差纹理A", 2D) = "white" {}
		MainTex2("视差纹理B", 2D) = "white" {}
		_liangIntensity("亮度A", Float) = 0
		_liangIntensity1("亮度B", Float) = 0
		[HDR]_YemianColor("液面加颜色", Color) = (0,0,0,0)
		_yemianbaidong("液面摆动z", Float) = 0
		_yemianbaidong1("液面摆动x", Float) = 0
		_yemianHigh("液面高度", Range( 0 , 1)) = 0
		_Float2("波浪密度", Float) = 1
		_Float3("波浪速度", Float) = 1
		_Float5("波浪振幅", Float) = 0.5
		MianTexSpeedx("主纹理速度x", Float) = 0
		MianTexSpeedy1("主纹理速度y", Float) = 0
		_MainTex("MainTex", 2D) = "white" {}
		MianTexItensidy("主纹理亮度", Float) = 0
		[HDR]EdgeColor("边缘光颜色", Color) = (1,1,1,1)
		Vce3xyz("边缘光设置_X底色_Y亮度_Z宽度", Vector) = (0,0,0,0)

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
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D MainTex;
			uniform float4 _DesSpeed;
			uniform float Parallax;
			uniform float _liangIntensity;
			uniform float4 _DesSpeed1;
			uniform float _liangIntensity1;
			uniform float4 EdgeColor;
			uniform float3 Vce3xyz;
			uniform sampler2D _MainTex;
			uniform float MianTexSpeedx;
			uniform float MianTexSpeedy1;
			uniform float MianTexItensidy;
			uniform float _yemianHigh;
			uniform float4 _DesSpeed3;
			uniform float _yemianbaidong;
			uniform float _yemianbaidong1;
			uniform float _Float2;
			uniform float _Float3;
			uniform float _Float5;
			uniform sampler2D MainTex2;
			uniform float4 _DesSpeed2;
			uniform float4 _YemianColor;
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
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
			
			fixed4 frag (v2f i , bool ase_vface : SV_IsFrontFace) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 appendResult20 = (float2(_DesSpeed.z , _DesSpeed.w));
				float2 texCoord16 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult19 = (float2(_DesSpeed.x , _DesSpeed.y));
				float2 panner22 = ( 1.0 * _Time.y * appendResult20 + ( texCoord16 * appendResult19 ));
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeResult2 = normalize( ase_worldViewDir );
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 objToWorld5 = mul( unity_ObjectToWorld, float4( ase_worldNormal, 1 ) ).xyz;
				float3 normalizeResult6 = normalize( objToWorld5 );
				float3 break10 = refract( normalizeResult2 , normalizeResult6 , ( 1.0 / Parallax ) );
				float2 appendResult11 = (float2(break10.x , break10.y));
				float2 Parallax13 = ( appendResult11 / break10.z );
				float2 appendResult30 = (float2(_DesSpeed1.z , _DesSpeed1.w));
				float2 appendResult29 = (float2(_DesSpeed1.x , _DesSpeed1.y));
				float2 panner33 = ( 1.0 * _Time.y * appendResult30 + ( texCoord16 * appendResult29 ));
				float4 AddColor42 = ( ( ( tex2D( MainTex, ( panner22 + float2( 0,0 ) + Parallax13 ) ) * _liangIntensity ) + float4( 0,0,0,0 ) ) + ( tex2D( MainTex, ( panner33 + float2( 0,0 ) + Parallax13 ) ) * _liangIntensity1 ) );
				float fresnelNdotV111 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode111 = ( Vce3xyz.x + Vce3xyz.y * pow( 1.0 - fresnelNdotV111, Vce3xyz.z ) );
				float2 appendResult102 = (float2(MianTexSpeedx , MianTexSpeedy1));
				float2 texCoord99 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner100 = ( 1.0 * _Time.y * appendResult102 + texCoord99);
				float4 tex2DNode104 = tex2D( _MainTex, panner100 );
				float4 transform57 = mul(unity_ObjectToWorld,_DesSpeed3);
				float3 rotatedValue62 = RotateAroundAxis( float3( 0,0,0 ), i.ase_texcoord3.xyz, float3(1,0,0), 90.0 );
				float3 break71 = ( ( WorldPosition - (transform57).xyz ) + ( rotatedValue62 * _yemianbaidong ) + ( i.ase_texcoord3.xyz * _yemianbaidong1 ) );
				float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
				float3 temp_output_77_0 = ( 1.0 / ase_objectScale );
				float2 appendResult80 = (float2(break71.x , break71.z));
				float3 temp_cast_1 = (0.5).xxx;
				float3 break92 = ( ( sin( ( ( float3( appendResult80 ,  0.0 ) * temp_output_77_0 * _Float2 ) + ( _Float3 * _Time.y ) ) ) - temp_cast_1 ) * _Float5 );
				float Clip97 = step( ( ( (0.0 + (_yemianHigh - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) + ( break71.y * (temp_output_77_0).y ) ) + ( break92.x * break92.y ) ) , 0.5 );
				float2 appendResult46 = (float2(_DesSpeed2.z , _DesSpeed2.w));
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult45 = (float2(_DesSpeed2.x , _DesSpeed2.y));
				float2 panner49 = ( 1.0 * _Time.y * appendResult46 + ( (ase_screenPosNorm).xy * appendResult45 ));
				float4 Back53 = ( tex2D( MainTex2, panner49 ) + _YemianColor );
				float4 switchResult117 = (((ase_vface>0)?(( AddColor42 + ( ( EdgeColor * fresnelNode111 ) + ( ( tex2DNode104 * tex2DNode104.a * MianTexItensidy ) * Clip97 ) ) )):(Back53)));
				float4 appendResult119 = (float4(switchResult117.rgb , Clip97));
				
				
				finalColor = appendResult119;
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
Node;AmplifyShaderEditor.CommentaryNode;54;-325.849,1138.663;Inherit;False;1677.478;496.2747;Comment;11;43;44;45;46;47;48;49;50;52;51;53;背面基于屏幕空间的纹理;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-322.7043,308.1881;Inherit;False;2014.689;766.8656;Comment;24;16;28;20;18;29;30;31;21;22;23;25;26;27;19;24;32;33;34;36;39;35;37;40;42;正面双视差AB加颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;14;-333.4672,-281.3793;Inherit;False;1544.095;496.6295;Comment;12;3;4;10;11;12;13;1;2;5;6;8;7;视差UV计算//Parallax;1,1,1,1;0;0
Node;AmplifyShaderEditor.RefractOpVec;3;263,-202.5;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;4;-283.4672,-66.33057;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;10;537.4614,-175.6601;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;11;678.4171,-190.3868;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;845.6718,-160.9333;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;986.6274,-160.9333;Inherit;False;Parallax;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1;-266.2107,-231.3793;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;2;-44.47686,-182.5804;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;5;-103.1907,-76.97886;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;6;95.88451,-118.6065;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;122.6472,27.51859;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-201.4352,101.9035;Inherit;False;Property;Parallax;视差折射率;0;0;Create;False;0;0;0;False;0;False;0.2230301;3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-256.7683,364.5008;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;28;1282.301,424.3113;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-31.65378,664.188;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;18;-272.7043,569.1105;Inherit;False;Property;_DesSpeed;A_xy密度_zw速度;1;0;Create;False;0;0;0;False;0;False;0,0,0,0;1,1,0.52,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;93.34623,374.1881;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;509.3464,367.1881;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;1076.347,371.1881;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;988.346,492.1881;Inherit;False;Property;_liangIntensity;亮度A;7;0;Create;False;0;0;0;False;0;False;0;1.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-28.65377,575.188;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;316.562,479.3459;Inherit;False;13;Parallax;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;287.9785,748.6904;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;33;455.9791,744.6904;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;703.9787,741.6904;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;1270.979,745.6904;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;511.1951,853.8481;Inherit;False;13;Parallax;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;35;862.9779,732.6904;Inherit;True;Property;MainTex1;视差纹理A;5;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;25;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;37;1142.074,858.5096;Inherit;False;Property;_liangIntensity1;亮度B;8;0;Create;False;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;1539.985,582.5275;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;1494.901,775.5031;Inherit;False;AddColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;151.4366,851.0536;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;30;148.4366,940.0536;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;22;261.3463,370.1881;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;25;668.346,358.1881;Inherit;True;Property;MainTex;视差纹理A;5;0;Create;False;0;0;0;False;0;False;-1;None;ebc644d6e8cf3cd468a5a27e3b27b230;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;43;-275.849,1200.731;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;44;-3.948584,1210.161;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;45;-15.37461,1410.938;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;-18.3746,1499.938;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;199.8895,1221.976;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;396.8272,1215.663;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;50;601.827,1188.663;Inherit;True;Property;MainTex2;视差纹理B;6;0;Create;False;0;0;0;False;0;False;-1;None;6d5bfece2d65e9b4681dfc538c883003;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;1001.529,1322.108;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;1127.63,1314.308;Inherit;False;Back;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;56;-340.0247,1900.92;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;57;-141.0247,2106.92;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotateAboutAxisNode;62;21.96722,2352.669;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;47;-265.712,1403.289;Inherit;False;Property;_DesSpeed2;液面纹理_xy密度_zw速度;3;0;Create;False;0;0;0;False;0;False;0,0,0,0;5,5,0.01,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;31;-98.90082,843.4045;Inherit;False;Property;_DesSpeed1;B_xy密度_zw速度;2;0;Create;False;0;0;0;False;0;False;0,0,0,0;1,1,0.01,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;58;70.52534,2061.77;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;59;308.3584,1947.688;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;642.7084,2067.503;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;61;-302.6132,2634.217;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;245.5846,2684.46;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;348.6524,2299.154;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;68;36.673,2660.253;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;71;800.9041,2066.691;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;946.9041,2088.691;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;75;1090.904,1920.691;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;1352.904,2085.691;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;77;761.9041,2318.691;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectScaleNode;78;596.9041,2408.691;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;80;1141.904,2225.691;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;79;797.9041,2226.691;Inherit;False;False;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;1313.904,2303.691;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;1313.904,2559.691;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;85;958.9041,2646.691;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;1514.904,2322.691;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;87;1727.904,2350.691;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;1932.904,2336.691;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;2146.904,2338.691;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;92;2343.904,2336.691;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;2516.904,2339.691;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;2496.543,2190.146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;95;2802.543,2205.146;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;2962.543,2200.146;Inherit;False;Clip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;99;2048.895,534.7162;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;100;2355.866,526.6116;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;102;2274.486,691.4486;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;104;2605.486,514.4486;Inherit;True;Property;_MainTex;MainTex;18;0;Create;True;0;0;0;False;0;False;-1;None;6d5bfece2d65e9b4681dfc538c883003;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;2987.486,544.4486;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;3092.486,692.4486;Inherit;False;97;Clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;3157.486,533.4486;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;3327.486,502.4486;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;111;2955.486,329.4486;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;3251.029,314.0919;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;3524.782,475.8309;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;3431.122,371.6174;Inherit;False;42;AddColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;117;3738.486,490.3418;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;3502.356,601.1513;Inherit;False;53;Back;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;4074.148,478.7129;Float;False;True;-1;2;ASEMaterialInspector;100;5;41YeMian;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;119;3969.206,567.2584;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;3738.206,637.2584;Inherit;False;97;Clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;2850.486,688.4486;Inherit;False;Property;MianTexItensidy;主纹理亮度;19;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;2078.186,696.4486;Inherit;False;Property;MianTexSpeedx;主纹理速度x;16;0;Create;False;0;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;2078.486,777.4486;Inherit;False;Property;MianTexSpeedy1;主纹理速度y;17;0;Create;False;0;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;113;3038.552,152.8175;Inherit;False;Property;EdgeColor;边缘光颜色;20;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;51;679.1292,1396.209;Inherit;False;Property;_YemianColor;液面加颜色;9;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;1,0.995283,0.995283,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;55;-342.3582,2100.708;Inherit;False;Property;_DesSpeed3;液面裁剪;4;0;Create;False;0;0;0;False;0;False;0,0,0,1;5,5,0.1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;64;-349.9078,2342.032;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;65;-332.8774,2490.662;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;0;False;0;False;90;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;602.9041,2308.09;Inherit;False;Constant;_Float1;Float 1;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;794.9041,1935.692;Inherit;False;Property;_yemianHigh;液面高度;12;0;Create;False;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;1105.904,2434.691;Inherit;False;Property;_Float2;波浪密度;13;0;Create;False;0;0;0;False;0;False;1;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;1106.904,2562.691;Inherit;False;Property;_Float3;波浪速度;14;0;Create;False;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;1789.904,2427.691;Inherit;False;Constant;_Float4;Float 4;15;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;1978.904,2430.691;Inherit;False;Property;_Float5;波浪振幅;15;0;Create;False;0;0;0;False;0;False;0.5;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;2724.543,2365.146;Inherit;False;Constant;_Float6;Float 6;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;110;2631.486,344.4486;Inherit;False;Property;Vce3xyz;边缘光设置_X底色_Y亮度_Z宽度;21;0;Create;False;0;0;0;False;0;False;0,0,0;-0.83,1,2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;67;135.1813,2500.458;Inherit;False;Property;_yemianbaidong;液面摆动z;10;0;Create;False;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;66.99547,2860.928;Inherit;False;Property;_yemianbaidong1;液面摆动x;11;0;Create;False;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
WireConnection;3;0;2;0
WireConnection;3;1;6;0
WireConnection;3;2;8;0
WireConnection;10;0;3;0
WireConnection;11;0;10;0
WireConnection;11;1;10;1
WireConnection;12;0;11;0
WireConnection;12;1;10;2
WireConnection;13;0;12;0
WireConnection;2;0;1;0
WireConnection;5;0;4;0
WireConnection;6;0;5;0
WireConnection;8;1;7;0
WireConnection;28;0;26;0
WireConnection;20;0;18;3
WireConnection;20;1;18;4
WireConnection;21;0;16;0
WireConnection;21;1;19;0
WireConnection;23;0;22;0
WireConnection;23;2;24;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;19;0;18;1
WireConnection;19;1;18;2
WireConnection;32;0;16;0
WireConnection;32;1;29;0
WireConnection;33;0;32;0
WireConnection;33;2;30;0
WireConnection;34;0;33;0
WireConnection;34;2;39;0
WireConnection;36;0;35;0
WireConnection;36;1;37;0
WireConnection;35;1;34;0
WireConnection;40;0;28;0
WireConnection;40;1;36;0
WireConnection;42;0;40;0
WireConnection;29;0;31;1
WireConnection;29;1;31;2
WireConnection;30;0;31;3
WireConnection;30;1;31;4
WireConnection;22;0;21;0
WireConnection;22;2;20;0
WireConnection;25;1;23;0
WireConnection;44;0;43;0
WireConnection;45;0;47;1
WireConnection;45;1;47;2
WireConnection;46;0;47;3
WireConnection;46;1;47;4
WireConnection;48;0;44;0
WireConnection;48;1;45;0
WireConnection;49;0;48;0
WireConnection;49;2;46;0
WireConnection;50;1;49;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;53;0;52;0
WireConnection;57;0;55;0
WireConnection;62;0;64;0
WireConnection;62;1;65;0
WireConnection;62;3;61;0
WireConnection;58;0;57;0
WireConnection;59;0;56;0
WireConnection;59;1;58;0
WireConnection;60;0;59;0
WireConnection;60;1;66;0
WireConnection;60;2;69;0
WireConnection;69;0;68;0
WireConnection;69;1;70;0
WireConnection;66;0;62;0
WireConnection;66;1;67;0
WireConnection;71;0;60;0
WireConnection;72;0;71;1
WireConnection;72;1;79;0
WireConnection;75;0;74;0
WireConnection;73;0;75;0
WireConnection;73;1;72;0
WireConnection;77;0;76;0
WireConnection;77;1;78;0
WireConnection;80;0;71;0
WireConnection;80;1;71;2
WireConnection;79;0;77;0
WireConnection;81;0;80;0
WireConnection;81;1;77;0
WireConnection;81;2;82;0
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;86;0;81;0
WireConnection;86;1;84;0
WireConnection;87;0;86;0
WireConnection;88;0;87;0
WireConnection;88;1;89;0
WireConnection;90;0;88;0
WireConnection;90;1;91;0
WireConnection;92;0;90;0
WireConnection;93;0;92;0
WireConnection;93;1;92;1
WireConnection;94;0;73;0
WireConnection;94;1;93;0
WireConnection;95;0;94;0
WireConnection;95;1;96;0
WireConnection;97;0;95;0
WireConnection;100;0;99;0
WireConnection;100;2;102;0
WireConnection;102;0;101;0
WireConnection;102;1;103;0
WireConnection;104;1;100;0
WireConnection;105;0;104;0
WireConnection;105;1;104;4
WireConnection;105;2;106;0
WireConnection;107;0;105;0
WireConnection;107;1;108;0
WireConnection;109;0;112;0
WireConnection;109;1;107;0
WireConnection;111;1;110;1
WireConnection;111;2;110;2
WireConnection;111;3;110;3
WireConnection;112;0;113;0
WireConnection;112;1;111;0
WireConnection;114;0;115;0
WireConnection;114;1;109;0
WireConnection;117;0;114;0
WireConnection;117;1;118;0
WireConnection;0;0;119;0
WireConnection;119;0;117;0
WireConnection;119;3;120;0
ASEEND*/
//CHKSM=C316201F3193AADCF87149D53B67FFAEDF745999