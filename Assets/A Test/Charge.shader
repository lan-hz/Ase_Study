Shader "Test"
{
    Properties
    {
        [HDR]ChargeColor("主颜色", Color) = (0, 0, 0, 0)
        [HDR]ChargeNoiseColor("NoiseColor", Color) = (1, 1, 1, 1)
        _Angle("角度(%)", Range(0, 100)) = 0
        _Ply("环宽度", Range(0, 50)) = 3.23
        _Speed("扰动速度", Range(0, 3)) = 0
        _Intens("底环透明度", Range(0, 1)) = 0
        ChargeNoise("扰动贴图", 2D) = "white" {}

    }

    SubShader
    {


        Tags {
        "RenderType" = "Opaque" "Queue" = "Transparent" }
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
        Offset 0, 0



        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };


            sampler2D ChargeNoise;
            half4 ChargeColor;
            half _Angle;
            half _Ply;
            half _Intens;
            half4 ChargeNoiseColor;
            half _Speed;
            half4 ChargeNoise_ST;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.uv1.xy = v.uv.xy;
                o.uv1.zw = v.uv1.xy;

                o.vertex = UnityObjectToClipPos(v.vertex);


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);


                half2 splitUv = i.uv1.xy * float2(100, 100);
                half tempOutPut = step((100.0 + _Angle * -1.0), splitUv.x);
                half stepSplitUv = step(splitUv.y, _Ply);
                half temp_output_97_0 = ((1.0 - tempOutPut) * stepSplitUv);
                half4 temp_cast_0 = ((temp_output_97_0 * _Intens)).xxxx;
                half2 uv2ChargeNoise = i.uv1.zw * ChargeNoise_ST.xy + ChargeNoise_ST.zw;
                half2 temp_cast_2 = (uv2ChargeNoise.x).xx;
                half2 panner55 = (1.0 * _Time.y * _Speed + temp_cast_2);
                half4 lerpResult = lerp(temp_cast_0, ChargeNoiseColor, tex2D(ChargeNoise, panner55).r);
                fixed4 finalColor = (ChargeColor * tempOutPut * stepSplitUv) + (temp_output_97_0 * lerpResult);


                return finalColor;
            }
            ENDCG
        }
    }
    Fallback Off
}
