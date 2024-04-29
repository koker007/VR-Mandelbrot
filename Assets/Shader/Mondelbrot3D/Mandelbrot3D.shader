Shader "Explorer/Mandelbrot3D"
{
    Properties
    {
        _MaxIterMandel("Iteration Mandel Max", Int) = 100
        _MaxIterMarch("Iteration March Max", Int) = 40
        _CamPos("Camera Position", Vector) = (0, 0, 0, 0)
        _StartStep("Start Ray Step", Range(0.0000001, 0.001)) = 0.001
        _PosZ("PosZ", Range(-2, 2)) = 0
        _EyeAngle("EyeAngle", Range(40, 100)) = 90
        _EyeIndex("EyeIndex", Range(0, 1)) = 0
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
                // Начальные значения для рисунка Мандельброта
                float2 z = float2(0.0, 0.0);
                float iter;

                // Вычисление рисунка Мандельброта
                for (iter = 0; iter < iterMax; iter++) {
                    z = float2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + pos;
                    if (length(z) > 2) break;
                }

                // Преобразуем результат в цвет
                float normalizedIter = iter / iterMax;
                return normalizedIter;
            }
            float MandelBulb(float x, float y, float z, float iterMax) {
                    // Начальные значения для рисунка Мандельброта
                    float3 zeta = float3(x,y,z);
                    float n = 8;

                    float iter;
                    for (iter = 0; iter < iterMax; iter++) {
                        //преобразуем координаты в сферические
                        float r = sqrt(zeta.x * zeta.x + zeta.y * zeta.y + zeta.z * zeta.z);
                        float theta = atan2(sqrt(zeta.x * zeta.x + zeta.y * zeta.y), zeta.z);
                        float phi = atan2(zeta.y, zeta.z);

                        //находим позицию в координатах
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

                    // Преобразуем результат в цвет
                    float normalizedIter = iter / iterMax;

                    return normalizedIter;
                }
            float3 GetRayVector(float2 uv, float eyeAngle) {
                //меняем ui от -1 до 1 // чтобы луч в uv 0.0 бросался прямо вперед
                float2 UV = uv * 2 - 1;
                float angleHalf = eyeAngle/2;


                float3 angleRay = float3(sin((UV.x * angleHalf * 3.14159)/180), sin((UV.y * angleHalf * 3.14159) / 180), 1);

                return normalize(angleRay);
            }

            float random(float2 uv) {
                return frac(sin(dot(uv,float2(12.9898, 78.233))) * 43758.5453123);
            }

            float3 RayMarching(float3 posStart, float rayStepStart, float3 rayVector, int iterMachMax, int iterMandelMax) {
                float3 result = float3(0.0f,0.0f,0.0f);

                float rayStep = rayStepStart;
                float rayStepAll = rayStep;

                float3 posNow = posStart + rayVector * rayStep;
                int iterMach = 0;

                for (; iterMach < iterMachMax; iterMach++) {
                    //Проверяем бульбу на попадание луча
                    float mandel = MandelBulb(posNow.x, posNow.y, posNow.z, iterMandelMax);
                    
                    if (mandel > 0.99f)
                        break;

                    rayStep = rayStep * 1.01f;
                    rayStepAll += rayStep;
                    posNow = posNow + rayVector * rayStep;
                }

                float iterFloat = iterMach;

                float coofIter = 1.0f - (iterFloat / iterMachMax);

                result = float3(coofIter, coofIter, coofIter);

                return result;
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                uint eyeIndex : SV_RenderTargetArrayIndex;
            };

            sampler2D _MainTex;
            int _MaxIterMandel;
            int _MaxIterMarch;
            float _PosZ;
            float _StartStep;
            float _EyeAngle;
            float _EyeIndex;
            float4 _CamPos;
            uniform float4x4 _RotationMatrix;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.eyeIndex = unity_StereoEyeIndex;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //random Quit
                if (random(i.uv) > 0.5f) {
                    return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                }
                
                //Left eye
                if (i.eyeIndex == 0)
                {
                    if (_EyeIndex >= 0.5f) {
                        return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                    }
                }

                //Right eye
                if (i.eyeIndex != 0){
                    if (_EyeIndex < 0.5f) {
                        return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                    }
                }

            // Нормализуем координаты пикселя
                float2 UV = i.uv *4.0 - 2.0;
                
                // Начальные значения для рисунка Мандельброта
                float3 pos = float3(UV.x, UV.y, _PosZ);


                float result = 0;
                //result = Mandelbrot(UV, _MaxIter);
                //result = MandelBulb(_PosZ, UV.x, UV.y, _MaxIterMandel);

                float4 vectorRay4 = float4(GetRayVector(i.uv, _EyeAngle), 1.0f);
                float4 vectorRayResult = MultiplyMatrixVector(_RotationMatrix, vectorRay4); // Выполняем умножение матрицы

                float3 posStart = float3(_CamPos.x, _CamPos.y, _CamPos.z);

                float3 colorResult = RayMarching(posStart, _StartStep, vectorRayResult.xyz, _MaxIterMarch, _MaxIterMandel);

                return fixed4(colorResult.r, colorResult.g, colorResult.b, 1.0);
            }
            ENDCG
        }
    }
}
