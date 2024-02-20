Shader"ENTI/02_Vertex_Unlit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "WHITE" {}
        _Scale ("Scale", float) = 1.0
        _TilingOffset ("Tiling and Offset", vector) = (1.0, 1.0, 1.0, 1.0)
        _Displacement ("Displacement", float) = 1.0
        _DisplacementTexture ("Displacement Texture", 2D) = "WHITE" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float4 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 displacementTexture : TEXCOORD1;
};

            fixed4 _Color;
            float4 _MainTex_ST, _DisplacementTexture_ST;
            sampler2D _MainTex, _DisplacementTexture;
            float _Scale;
            float4 _TilingOffset;
            float _Displacement;

            v2f vert (appdata v)
            {
                v2f o;
    
                float2 local_uv = v.uv;
                local_uv *= _TilingOffset.xy;
                local_uv += _TilingOffset.zw;
    
                o.uv = TRANSFORM_TEX(local_uv, _MainTex);
    
                /*
                //1. VISUALIZE COMPONENTS
    
                //normal
                o.color.xyz = v.normal * 0.5 + 0.5;
    
                //tangent
                o.color.xyz = v.tangent * 0.5 + 0.5;
    
                //bitanget
                float3 bitangent = cross(v.normal, v.tangent);
                o.color.xyz = bitangent * 0.5 + 0.5;
                o.color.w = 1.0;
    
                //uv
                o.color = float4(v.uv.xy, 0, 0);*/
    
                //2. DISPLACEMENTS
    
                v.vertex *= _Scale;
    
                float3 worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
    
                half4 displacementTexture = tex2Dlod(_DisplacementTexture, float4(worldPosition.x * _Time.x, worldPosition.y, 0, 0));
    
                v.vertex.xyz += _Displacement * v.normal * displacementTexture;
    
                o.displacementTexture = displacementTexture;
    
                o.vertex = UnityObjectToClipPos(v.vertex);
    
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                half4 col = tex2D(_MainTex, i.uv);
                col += (i.displacementTexture * _Color);
                return col;
            }
            ENDCG
        }
    }
}
