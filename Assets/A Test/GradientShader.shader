Shader "Custom/GradientShader"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1, 1, 1, 1)
        _Color2 ("Color 2", Color) = (0, 0, 0, 1)
        _GradientSpeed ("Gradient Speed", Range(0.01, 1)) = 0.1
    }

    SubShader
    {
        Tags {
        "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float4 uv : TEXCOORD1;
            };

            float4 _Color1;
            float4 _Color2;
            float _GradientSpeed;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv.xy = v.vertex.xy;
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                float t = _GradientSpeed * _Time.y;
                float x = i.uv.x;
                float3 color = lerp(_Color1.rgb, _Color2.rgb, x / _ScreenParams.x + t);
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
