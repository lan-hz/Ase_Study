Shader "Custom/MobileSign"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        [HDR]_MainColor("颜色", Color) = (0, 0, 0, 0)
        _Speed("速度", Range(0, 1)) = 1
        [Toggle]_Dir("方向", Float) = 0
    }
    SubShader
    {
        Tags {
        "RenderType" = "Opaque" "Queue" = "Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            #pragma multi_compile_instancing

            sampler2D _MainTex;
            UNITY_INSTANCING_BUFFER_START(Props)
            half _Speed;
            float4 _MainTex_ST;
            half _Dir;
            fixed4 _MainColor;
            UNITY_INSTANCING_BUFFER_END(Props)

            struct v2f
            {
                half4 vert : SV_POSITION;
                half4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.uv = v.texcoord;
                o.vert = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                fixed4 finalColor = 1;
                float mulTime = _Time.y * -1.0;
                float speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
                float2 appendResult = float2(0.0, speed * 3);

                float4 mainTex_ST = UNITY_ACCESS_INSTANCED_PROP(Props, _MainTex_ST);
                float2 uv_MainTex = i.uv.xy * mainTex_ST.xy + mainTex_ST.zw;
                float dir = UNITY_ACCESS_INSTANCED_PROP(Props, _Dir);
                uv_MainTex.y *= lerp(1, -1, dir);
                float2 panner = (mulTime * appendResult + uv_MainTex);

                float4 tex2DNode = tex2D(_MainTex, panner);
                clip(tex2DNode.a - 0.0001);
                fixed4 mainColor = UNITY_ACCESS_INSTANCED_PROP(Props, _MainColor);

                finalColor.rgb = tex2DNode.rgb;
                finalColor *= mainColor;

                return finalColor;
            }
            ENDCG
        }
    }
}
