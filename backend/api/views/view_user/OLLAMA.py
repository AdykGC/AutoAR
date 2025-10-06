from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets
from rest_framework.decorators import api_view
from rest_framework.response import Response
# ---------- AUTH ---------- 
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes

# ---------- MODEL ---------- 
from api.models import *

# ---------- SERIALIZER ---------- 
from api.serializers import *

# ---------- LOGS & API ---------- 
import os
import logging
import ollama

# ---------- METHOD ---------- 
logger = logging.getLogger(__name__)


"""
Обработчик POST-запроса к локальной LLM через Ollama
    | Ожидает JSON с CV пользователя
    | Ожидает текстовое описание вакансий
    | Возвращает JSON с сгенерированным и подкорректированным CV
"""
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def ollama_generate_cv(request):

    user_cv = request.data.get('user_cv')
    job_description = request.data.get('job_description')
    prompt = f""" Ты — опытный карьерный консультант. Вот резюме пользователя: {user_cv}
                Вот вакансия, под которую нужно адаптировать резюме: {job_description}

                    Перепиши резюме так, чтобы оно максимально подходило под вакансию.
                    Формулируй чётко и профессионально. Убирай нерелевантное, усиливай релевантное.
                    Верни только обновлённый текст резюме. Без лишних пояснений.
                """

    if not user_cv or not job_description:
        return Response (
                {'error': '"CV" and "Job description" are required.'},
                status=400
            )

    try:
        response = ollama.chat(
            model='gemma3:1b',
            messages=[
                {"role": "user", "content": prompt}
            ]
        )
        reply = response['message']['content'].strip()
        return Response({'cv': reply})

    except Exception as e:
        logger.error(f"Ошибка при запросе к Ollama: {e}")
        return Response({'error': str(e)}, status=500)
