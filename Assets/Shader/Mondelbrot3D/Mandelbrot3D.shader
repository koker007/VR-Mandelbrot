Shader "Explorer/Mandelbrot3D"
{
    Properties
    {
        _MaxIterMandel("Iteration Mandel Max", Int) = 100
        _MaxIterMarch("Iteration March Max", Int) = 40
        _CamPos("Camera Position", Vector) = (0, 0, 0, 0)
        _StartStep("Start Ray Step", Range(0.0001, 0.01)) = 0.001
        _PosZ("PosZ", Range(-2, 2)) = 0
        _EyeAngle("EyeAngle", Range(40, 100)) = 90
        _EyeIndex("EyeIndex", Range(0, 1)) = 0
        _FillingPercent("FillingPercent", Range(0.01, 1.0)) = 0.11
        _Yaw("Yaw", Range(-180, 180)) = 0
        _Pitch("Pitch", Range(-90, 90)) = 0
        _LightNormalOffset("LightNormalOffset", Range(0.1, 0.01)) = 0.1

        _LightDir("Light Direction", Vector) = (1, 1, 1, 0)
        _LightIntensity("Light Intensity", Range(0.1, 2.0)) = 1.0
        _AmbientLight("Ambient Light", Range(0.0, 0.5)) = 0.1
    }
        SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float Mandelbrot(float2 pos, float iterMax) {
                // ��������� �������� ��� ������� ������������
                float2 z = float2(0.0, 0.0);
                float iter;

                // ���������� ������� ������������
                for (iter = 0; iter < iterMax; iter++) {
                    z = float2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + pos;
                    if (length(z) > 2) break;
                }

                // ����������� ��������� � ����
                float normalizedIter = iter / iterMax;
                return normalizedIter;
            }
            float MandelBulb(float x, float y, float z, float iterMax) {
                    // ��������� �������� ��� ������� ������������
                    float3 zeta = float3(x,y,z);
                    float n = 8;

                    float iter;
                    for (iter = 0; iter < iterMax; iter++) {
                        //����������� ���������� � �����������
                        float r = sqrt(zeta.x * zeta.x + zeta.y * zeta.y + zeta.z * zeta.z);
                        float theta = atan2(sqrt(zeta.x * zeta.x + zeta.y * zeta.y), zeta.z);
                        float phi = atan2(zeta.y, zeta.z);

                        //������� ������� � �����������
                        float newx = pow(r, n) * sin(theta * n) * cos(phi * n);
                        float newy = pow(r, n) * sin(theta * n) * sin(phi * n);
                        float newz = pow(r, n) * cos(theta * n);

                        zeta.x = newx + x;
                        zeta.y = newy + y;
                        zeta.z = newz + z;

                        if (r > 16) {
                            break;
                        }
                    }

                    // ����������� ��������� � ����
                    float normalizedIter = iter / iterMax;

                    return normalizedIter;
                }
            float3 GetRayVector(float2 uv, float eyeAngle) {
                //������ ui �� -1 �� 1 // ����� ��� � uv 0.0 �������� ����� ������
                float2 UV = uv * 2 - 1;
                float angleHalf = eyeAngle/2;


                float3 angleRay = float3(sin((UV.x * angleHalf * 3.14159)/180), sin((UV.y * angleHalf * 3.14159) / 180), 1);

                return normalize(angleRay);
            }

            float random(float2 uv) {
                return frac(sin(dot(uv,float2(12.9898, 78.233))) * 43758.5453123);
            }

            float3 ComputeNormal(float3 p, float epsilon, int iterMax) {
                float dx = (MandelBulb(p.x + epsilon, p.y, p.z, iterMax) - 
                           MandelBulb(p.x - epsilon, p.y, p.z, iterMax)) / (2.0 * epsilon);
                float dy = (MandelBulb(p.x, p.y + epsilon, p.z, iterMax) - 
                           MandelBulb(p.x, p.y - epsilon, p.z, iterMax)) / (2.0 * epsilon);
                float dz = (MandelBulb(p.x, p.y, p.z + epsilon, iterMax) - 
                           MandelBulb(p.x, p.y, p.z - epsilon, iterMax)) / (2.0 * epsilon);
                return normalize(float3(dx, dy, dz));
            }

            float3 RayMarching(float3 posStart, float rayStepStart, float3 rayVector, int iterMachMax, int iterMandelMax, float lightNormalOffset, float3 lightDir, float lightIntensity, float ambientLight) {
                float3 result = float3(0.0f,0.0f,0.0f);

                float rayStep = rayStepStart;
                float rayStepAll = rayStep;

                float3 posNow = posStart + rayVector * rayStep;
                int iterMach = 0;
                float mandel = 0.0f;

                bool firstInside = true;
                for (; iterMach < iterMachMax; iterMach++) 
                {
                    //��������� ������ �� ��������� ����
                    mandel = MandelBulb(posNow.x, posNow.y, posNow.z, iterMandelMax);
                    
                    //���������
                    if (mandel > 0.50f && !firstInside)
                    {
                        break;
                    }


                    rayStep = rayStep * 1.009f;
                    rayStepAll += rayStep;
                    posNow += rayVector * rayStep;

                    if(iterMach > 50)
                        firstInside = false;
                }

                if (iterMach < iterMachMax) 
                {
                    // ��������� �� ������ normalizedIter (mandel)
                    float hue = 0 + mandel * 1.0f; // ����������� � ���� ��� ��������� �����
                    float3 color = float3(sin(hue) * posNow.x, cos(hue + posNow.y), 1.0 - sin(hue + posNow.z)); // RGB-����
                    result = clamp(color, 0.0f, 1.0f); // ������������ �������� �� 0 �� 1

                    float3 normal = ComputeNormal(posNow, lightNormalOffset, iterMandelMax);
                    float3 normalizedLightDir = normalize(lightDir);
                    float diffuse = max(0.0f, dot(normal, normalizedLightDir));
                    float3 lighting = color * (diffuse * lightIntensity + ambientLight);
                    result = clamp(lighting, 0.0f, 1.0f);
                }

                float iterFloat = iterMach;

                float coofIter = 1.0f - (iterFloat / iterMachMax);

                result *= coofIter;  //float3(coofIter, coofIter, coofIter);

                return result;
            }

            float4x4 CreateRotationMatrix(float yaw, float pitch) {
                float radYaw = radians(yaw);
                float radPitch = radians(pitch);
                float4x4 yawMatrix = float4x4(
                    cos(radYaw), 0, sin(radYaw), 0,
                    0, 1, 0, 0,
                    -sin(radYaw), 0, cos(radYaw), 0,
                    0, 0, 0, 1
                );
                float4x4 pitchMatrix = float4x4(
                    1, 0, 0, 0,
                    0, cos(radPitch), -sin(radPitch), 0,
                    0, sin(radPitch), cos(radPitch), 0,
                    0, 0, 0, 1
                );
                return mul(yawMatrix, pitchMatrix);
            }

            float4 MultiplyMatrixVector(const float4x4 mat, const float4 vec)
            {
                float4 result;

                result.x = dot(mat[0], vec);
                result.y = dot(mat[1], vec);
                result.z = dot(mat[2], vec);
                result.w = dot(mat[3], vec);

                return result;
            }


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            int _MaxIterMandel;
            int _MaxIterMarch;
            float _PosZ;
            float _StartStep;
            float _EyeAngle;
            float _EyeIndex;
            float _FillingPercent;
            float4 _CamPos;
            float _Yaw;
            float _Pitch;
            float _LightNormalOffset;

            float4 _LightDir;
            float _LightIntensity;
            float _AmbientLight;
            uniform float4x4 _RotationMatrix;

            v2f vert(appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v); //Insert
                UNITY_INITIALIZE_OUTPUT(v2f, o); //Insert
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i); //Insert

                //random Quit
                if (random(i.uv) > _FillingPercent) {
                    return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                }
                
                //Left eye
                if (unity_StereoEyeIndex == 0)
                {
                    if (_EyeIndex >= 0.5f) {
                        return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                    }
                }

                //Right eye
                if (unity_StereoEyeIndex != 0){
                    if (_EyeIndex < 0.5f) {
                        return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                    }
                }

            // ����������� ���������� �������
                float2 UV = i.uv *4.0 - 2.0;
                
                // ��������� �������� ��� ������� ������������
                float3 pos = float3(UV.x, UV.y, _PosZ);


                float result = 0;
                //result = Mandelbrot(UV, _MaxIter);
                //result = MandelBulb(_PosZ, UV.x, UV.y, _MaxIterMandel);

                float4 vectorRay4 = float4(GetRayVector(i.uv, _EyeAngle), 1.0f);
                float4x4 rotationMatrix = CreateRotationMatrix(_Yaw, _Pitch);
                float4 vectorRayResult = MultiplyMatrixVector(rotationMatrix, vectorRay4); // ��������� ��������� �������

                float3 posStart = float3(_CamPos.x, _CamPos.y, _CamPos.z);

                float3 colorResult = RayMarching(posStart, _StartStep, vectorRayResult.xyz, _MaxIterMarch, _MaxIterMandel, _LightNormalOffset, _LightDir.xyz, _LightIntensity, _AmbientLight);

                return fixed4(colorResult.r, colorResult.g, colorResult.b, 1.0);
            }
            ENDCG
        }
    }
}
