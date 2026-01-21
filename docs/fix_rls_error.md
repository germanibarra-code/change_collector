# � Solución Segura: Trigger Automático para user_login

## ✅ Solución Correcta y Segura

En lugar de insertar manualmente desde la app, usaremos un **trigger de Supabase** que automáticamente crea el registro en `user_login` cuando un usuario se registra.

## 📝 Script SQL Completo

Ejecuta este script en **SQL Editor** de Supabase:

```sql
-- 1. AGREGAR columna user_id a user_login (si no existe)
ALTER TABLE public.user_login 
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- 2. Hacer user_id único
ALTER TABLE public.user_login 
  ADD CONSTRAINT user_login_user_id_key UNIQUE (user_id);

-- 3. Configurar valores por defecto
ALTER TABLE public.user_login 
  ALTER COLUMN created_at SET DEFAULT NOW(),
  ALTER COLUMN updated_at SET DEFAULT NOW(),
  ALTER COLUMN status SET DEFAULT true,
  ALTER COLUMN password_hash DROP NOT NULL;

-- 4. CREAR función que se ejecuta cuando un usuario se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_login (
    user_id,
    first_name,
    last_name,
    date_of_birth,
    email,
    status
  )
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    (NEW.raw_user_meta_data->>'birth_date')::date,
    NEW.email,
    true
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. CREAR trigger que ejecuta la función
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 6. Habilitar RLS con políticas seguras
ALTER TABLE public.user_login ENABLE ROW LEVEL SECURITY;

-- 7. Eliminar políticas antiguas
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.user_login;
DROP POLICY IF EXISTS "Enable read access for users based on email" ON public.user_login;
DROP POLICY IF EXISTS "Enable update for users based on email" ON public.user_login;

-- 8. CREAR políticas RLS seguras basadas en user_id
CREATE POLICY "Users can view their own profile"
  ON public.user_login
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON public.user_login
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 9. Trigger para updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_login_updated_at ON public.user_login;
CREATE TRIGGER update_user_login_updated_at
  BEFORE UPDATE ON public.user_login
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();
```

## � Cómo Funciona

1. **Usuario se registra** → Supabase crea usuario en `auth.users`
2. **Trigger se activa automáticamente** → Función `handle_new_user()` se ejecuta
3. **Datos se copian** → De `auth.users.raw_user_meta_data` a `user_login`
4. **Todo es automático** → No requiere código en la app

## 📊 Estructura Final de user_login

Tu tabla ahora tendrá:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | bigint | ID autoincremental |
| **`user_id`** | UUID | **NUEVO** - Referencia a auth.users(id) |
| `first_name` | varchar | Nombre |
| `last_name` | varchar | Apellido |
| `date_of_birth` | date | Fecha de nacimiento |
| `email` | varchar | Correo |
| `password_hash` | varchar | NULL |
| `status` | boolean | true/false |
| `created_at` | timestamp | Fecha creación |
| `updated_at` | timestamp | Fecha actualización |

## 🗑️ Eliminar Código de Inserción Manual

Ahora que el trigger hace todo automáticamente, **elimina** el código de inserción manual en `register_screen.dart`:

```dart
// ELIMINAR ESTE BLOQUE:
try {
  await supabase.from('user_login').insert({...});
} catch (dbError) {
  debugPrint('Error al guardar...');
}
```

Ya no es necesario porque el trigger lo hace automáticamente.

## ✅ Verificar que Funciona

Después de ejecutar el script:

1. Registra un nuevo usuario en la app
2. Ve a **Table Editor** > **user_login** en Supabase
3. Deberías ver el usuario con todos los campos llenos automáticamente

```sql
-- Verificar usuarios registrados
SELECT 
  ul.id,
  ul.user_id,
  ul.first_name,
  ul.last_name,
  ul.email,
  ul.status,
  ul.created_at,
  au.email_confirmed_at
FROM public.user_login ul
LEFT JOIN auth.users au ON ul.user_id = au.id
ORDER BY ul.created_at DESC;
```

## 🔒 Seguridad

Esta solución es **MÁS SEGURA** porque:
- ✅ Las políticas RLS solo permiten ver/editar datos propios
- ✅ No hay inserción manual desde la app
- ✅ El trigger usa `SECURITY DEFINER` (permisos elevados)
- ✅ Vincula correctamente con `auth.users` mediante `user_id`
