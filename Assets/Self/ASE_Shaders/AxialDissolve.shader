// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AxialDissolve"
{
	Properties
	{
		_Albedo("_Albedo", 2D) = "white" {}
		_Normal("_Normal", 2D) = "bump" {}
		_Metallic("_Metallic", 2D) = "white" {}
		_Emissive("_Emissive", 2D) = "white" {}
		_FigureTex("_FigureTex", 2D) = "white" {}
		_NoiseTex("_NoiseTex", 2D) = "white" {}
		[HDR]_EmissiveColor("_EmissiveColor", Color) = (1,1,1,0)
		[HDR]_EdgeColor("_EdgeColor", Color) = (1,1,1,0)
		[HDR]_FigureColor("_FigureColor", Color) = (2,2,2,1)
		_Height("_Height", Range( 0 , 1)) = 0.4631531
		_FigureLum("_FigureLum", Range( 0 , 1)) = 0
		_AllFigureLum("_AllFigureLum", Range( 0 , 1)) = 0
		_Compare("Compare", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float2 uv2_texcoord2;
			float2 uv3_texcoord3;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Emissive;
		uniform float4 _Emissive_ST;
		uniform float4 _EmissiveColor;
		uniform float _Height;
		uniform float4 _EdgeColor;
		uniform sampler2D _FigureTex;
		uniform float4 _FigureTex_ST;
		uniform float4 _FigureColor;
		uniform float _FigureLum;
		uniform float _AllFigureLum;
		uniform float _Compare;
		uniform sampler2D _NoiseTex;
		uniform float4 _NoiseTex_ST;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			o.Albedo = tex2D( _Albedo, uv_Albedo ).rgb;
			float2 uv_Emissive = i.uv_texcoord * _Emissive_ST.xy + _Emissive_ST.zw;
			float temp_output_11_0 = ( i.uv2_texcoord2.y + (-1.0 + (_Height - 0.0) * (0.5 - -1.0) / (1.0 - 0.0)) );
			float temp_output_26_0 = ( 1.0 - step( temp_output_11_0 , 0.49 ) );
			float2 uv2_FigureTex = i.uv2_texcoord2 * _FigureTex_ST.xy + _FigureTex_ST.zw;
			float2 uv3_NoiseTex = i.uv3_texcoord3 * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			float4 tex2DNode43 = tex2D( _NoiseTex, uv3_NoiseTex );
			float temp_output_61_0 = step( _Compare , ( tex2DNode43.r + 0.06892012 ) );
			o.Emission = ( ( tex2D( _Emissive, uv_Emissive ) * _EmissiveColor ) + ( ( temp_output_26_0 - ( 1.0 - step( temp_output_11_0 , 0.5 ) ) ) * _EdgeColor ) + ( ( tex2D( _FigureTex, uv2_FigureTex ) * _FigureColor * _FigureLum ) + ( _FigureColor * _AllFigureLum ) ) + ( _EdgeColor * ( temp_output_61_0 - step( _Compare , tex2DNode43.r ) ) ) ).rgb;
			float2 uv_Metallic = i.uv_texcoord * _Metallic_ST.xy + _Metallic_ST.zw;
			float4 tex2DNode4 = tex2D( _Metallic, uv_Metallic );
			o.Metallic = tex2DNode4.r;
			o.Smoothness = tex2DNode4.a;
			o.Alpha = saturate( ( saturate( temp_output_26_0 ) * temp_output_61_0 ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float2 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
				o.customPack2.xy = customInputData.uv3_texcoord3;
				o.customPack2.xy = v.texcoord2;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
				, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				surfIN.uv3_texcoord3 = IN.customPack2.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
					float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;63;-1639.777,1825.22;Inherit;False;1874.803;671.4;edge dissolution;8;52;56;43;42;55;61;51;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;28;-2379.229,226.881;Inherit;False;2077.015;744.3445;光边;13;12;21;10;17;15;11;14;16;27;26;19;20;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2329.229,501.6927;Inherit;False;Property;_Height;_Height;10;0;Create;True;0;0;0;False;0;False;0.4631531;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2205.171,294.836;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;21;-2029.923,527.2418;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1673.172,1023.73;Inherit;False;1503.642;666.6144;addFigure;8;29;33;32;36;30;34;31;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1926.052,302.9973;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1695.901,415.6242;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.49;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1699.166,637.6126;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;14;-1469.014,276.8811;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;16;-1484.955,653.3187;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-1623.172,1114.776;Inherit;False;1;30;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-1173.34,1490.191;Inherit;False;Property;_FigureLum;_FigureLum;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1160.219,1574.944;Inherit;False;Property;_AllFigureLum;_AllFigureLum;12;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-1169.764,1285.67;Inherit;False;Property;_FigureColor;_FigureColor;9;1;[HDR];Create;True;0;0;0;False;0;False;2,2,2,1;1.059274,1.059274,1.059274,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;27;-1196.081,600.5408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-1196.733,1084.16;Inherit;True;Property;_FigureTex;_FigureTex;5;0;Create;True;0;0;0;False;0;False;-1;9800e22a7c5bf554d9bc308fb15c66f7;9800e22a7c5bf554d9bc308fb15c66f7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;26;-1193.823,336.4067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-848.1807,412.3715;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-1093.656,-77.30118;Inherit;False;Property;_EmissiveColor;_EmissiveColor;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;2.996078,2.996078,2.996078,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1058.51,-337.3177;Inherit;True;Property;_Emissive;_Emissive;4;0;Create;True;0;0;0;False;0;False;-1;42e45d2e86da0254db16a72e119829b0;42e45d2e86da0254db16a72e119829b0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-686.2559,1345.865;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-796.2026,1073.73;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-515.5429,-133.4823;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-404.9319,1131.981;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-464.6145,431.8089;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;118.2227,-531.7227;Inherit;True;Property;_Albedo;_Albedo;1;0;Create;True;0;0;0;False;0;False;-1;d3dcb403dab0eac43adf72a8001079ca;d3dcb403dab0eac43adf72a8001079ca;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-262.9726,-142.5147;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;120.5227,-346.1227;Inherit;True;Property;_Normal;_Normal;2;0;Create;True;0;0;0;False;0;False;-1;acb4244d77de06449b9189d5dc6aae62;acb4244d77de06449b9189d5dc6aae62;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;509,-246;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AxialDissolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;2;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;0;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ColorNode;20;-824.5228,762.2249;Inherit;False;Property;_EdgeColor;_EdgeColor;8;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;2,1.838292,0.3113208,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-6.829652,-92.88656;Inherit;True;Property;_Metallic;_Metallic;3;0;Create;True;0;0;0;False;0;False;-1;73c2a93e42ef37c4d8c9e479490e6d59;73c2a93e42ef37c4d8c9e479490e6d59;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;265.3264,1104.261;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;58;158.4569,307.1848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;456.6157,676.4642;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;60;495.438,417.7101;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-930.4981,1875.468;Inherit;False;Property;_Compare;Compare;13;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-630.1519,2229.595;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-1219.812,1987.951;Inherit;True;Property;_NoiseTex;_NoiseTex;6;0;Create;True;0;0;0;False;0;False;-1;a162a71e9c580594a9708d2c26fd049b;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-1589.777,2030.834;Inherit;False;2;43;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;55;-0.3739452,2058.499;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;61;-304.1934,2243.22;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;51;-508.7908,1875.22;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-944.7579,2286.336;Inherit;False;Constant;_EdgeWidth;_EdgeWidth;14;0;Create;True;0;0;0;False;0;False;0.06892012;0;0;0.1;0;1;FLOAT;0
WireConnection;21;0;12;0
WireConnection;11;0;10;2
WireConnection;11;1;21;0
WireConnection;14;0;11;0
WireConnection;14;1;15;0
WireConnection;16;0;11;0
WireConnection;16;1;17;0
WireConnection;27;0;16;0
WireConnection;30;1;29;0
WireConnection;26;0;14;0
WireConnection;18;0;26;0
WireConnection;18;1;27;0
WireConnection;34;0;32;0
WireConnection;34;1;36;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;31;2;33;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;35;0;31;0
WireConnection;35;1;34;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;24;0;6;0
WireConnection;24;1;19;0
WireConnection;24;2;35;0
WireConnection;24;3;57;0
WireConnection;1;0;2;0
WireConnection;1;1;3;0
WireConnection;1;2;24;0
WireConnection;1;3;4;1
WireConnection;1;4;4;4
WireConnection;1;9;60;0
WireConnection;57;0;20;0
WireConnection;57;1;55;0
WireConnection;58;0;26;0
WireConnection;59;0;58;0
WireConnection;59;1;61;0
WireConnection;60;0;59;0
WireConnection;56;0;43;1
WireConnection;56;1;54;0
WireConnection;43;1;42;0
WireConnection;55;0;61;0
WireConnection;55;1;51;0
WireConnection;61;0;52;0
WireConnection;61;1;56;0
WireConnection;51;0;52;0
WireConnection;51;1;43;1
ASEEND*/
//CHKSM=5A1F65ED192866DAFB80D65AFC8ACEF45404B33B