Shader"ENTI/09_Triplanar"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white" {}
        _SecondaryTexture("Secondary Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Sharpness("Sharpness", Range(1, 64)) = 1.0
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
                float3 normal : NORMAL;
    
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 normal : NORMAL;
};

            fixed4 _Color;
            sampler2D _MainTexture, _SecondaryTexture;
            float4 _MainTexture_ST, _SecondaryTexture_ST;
            float _Sharpness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);      
    
                float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldPosition = worldPosition.xyz;
                o.normal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
    
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                
                float2 uv_front = TRANSFORM_TEX(i.worldPosition.yz, _MainTexture);
                float2 uv_top = TRANSFORM_TEX(i.worldPosition.xz, _SecondaryTexture);
                float2 uv_side = TRANSFORM_TEX(i.worldPosition.xy, _MainTexture);
                
                //read texture at uv position of 3 projections
                fixed4 color_front = tex2D(_MainTexture, uv_front);
                fixed4 color_top = tex2D(_SecondaryTexture, uv_top);
                fixed4 color_side = tex2D(_MainTexture, uv_side);
    
                //create weight through normals
                float3 weight = i.normal;
                weight = abs(weight);
                weight = pow(weight, _Sharpness);
                weight = weight / (weight.x + weight.y + weight.z);
    
                if (i.normal.y < 0.0)
                {
                    uv_top = TRANSFORM_TEX(i.worldPosition.xz, _MainTexture);
                    color_top = tex2D(_MainTexture, uv_top);
                }
    
                //Apply the weight to the texture
        color_front *= weight.x;
                color_top*= weight.y;
                color_side *= weight.z;
    
                fixed4 color = color_front + color_top + color_side;
    
                //Visualize weight
                //color.rgb = weight;
            
                return color;
}
            ENDCG
        }
    }
}
