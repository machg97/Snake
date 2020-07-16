function love.load()
  estado = 0
  t = 20 -- tamaño de cada celda
  timer = 0 -- Controlaremos el tiempo de ejecución con esta variable
  perder = false -- Para controlar cuando pierde el juego
  ganar = false -- Para controlar cuando gana el juego
  love.graphics.setBackgroundColor(0.6039, 0.7725, 0.0117) -- Colocaos un fondo verde
  area = {} -- Nos ayudará a definir un area de juego
  area.x = t -- La posición del area en la parte superior izquierda
  area.y = t * 2 --La posición del area en la parte inferior izquierda
  area.w = love.graphics.getWidth() - t * 2 -- (Width o Ancho) La posición del area en la parte superior derecha
  area.h = love.graphics.getHeight() - t * 3 -- (Height o Alto) La posición del area en la parte inferior derecha
  snake = {} -- Los datos de la serpiente
  snake.velX = 20 -- Velocidad inicial en X de la serpiente
  snake.velY = 0 -- Velocidad inicial en Y de la serpiente
  snake.cola = {} -- contiene todos los puntos x , y de cada parte de la serpiente
  snake.cola[0] = {x = area.x , y = area.y} -- Cabeza de la serpiente
  comida = {} -- Los datos de la comida
  comida.radio = 8 -- La comida será representada por un circulo, por lo que necesitamos un radio
  comida.offset = t/2 -- Ajuste de la posición del circulo en la celda.
  comida.x = (math.random((area.w - area.x)/t)) * t + area.x --Posición inicial random en el eje X
  comida.y = (math.random((area.h - area.y)/t)) * t + area.y -- Posición inicial random en el eje Y

end


function love.draw()

  love.graphics.setColor(0,0.1,0) -- El color que utilizaremos para dibujar el juego
  if not perder  and not ganar then -- Si no ha perdido o no ha ganado entonces...
    love.graphics.print("Puntuación: " .. #snake.cola * #snake.cola * 2, 16, 16) -- Imprimimos la Puntuación en la posición 16,16
    love.graphics.print("Estado: " .. estado, 16, 481) --
  elseif not perder and ganar then -- Si no ha perdido pero ha ganado entonces...
    love.graphics.print("Ganaste! presiona R para reiniciar :D" , 16 , 16) -- Imprimimos que ganamos en la posición 16,16
    love.graphics.print("Estado: " .. estado, 16, 481) --
  else -- Si no se cumplen las condiciones entonces
    love.graphics.print("Perdiste! Tu Puntuación es: " .. #snake.cola * #snake.cola * 2 .. ", presiona R para reiniciar", 16 , 16) -- Imprimimos que perdiste en la posición 16,16
    love.graphics.print("Estado: " .. estado, 16, 481) --
  end
  for i = 0, #snake.cola do -- Obtenemos cada contenido de snake.cola, es decir, cada x,y (cada parte de la serpiente)
    -- A continuación por cada Posición en x , y que tiene snake.cola, dibujaremos 4 cuadrados para simular el estilo retro del Nokia.
    love.graphics.rectangle("fill", snake.cola[i].x, snake.cola[i].y,t/2 - 1 , t/2 - 1)
    love.graphics.rectangle("fill", snake.cola[i].x + t/2, snake.cola[i].y, t/2 - 1, t/2 - 1)
    love.graphics.rectangle("fill", snake.cola[i].x, snake.cola[i].y + t/2, t/2 - 1, t/2 - 1)
    love.graphics.rectangle("fill", snake.cola[i].x + t/2, snake.cola[i].y + t/2, t/2 - 1, t/2 - 1)
  end
  love.graphics.rectangle("line", area.x, area.y, area.w , area.h ) --Dibujamos la linea que representará el area del juego
  love.graphics.circle("line", comida.x + comida.offset, comida.y + comida.offset, comida.radio) -- Dibujamos el circulo que representa la comida
end


function comer()
if snake.cola[0].x == comida.x and snake.cola[0].y == comida.y then -- Si la serpiente está encima de la comida entonces...
    snake.cola[#snake.cola + 1] = {x = snake.cola[#snake.cola].x - snake.velX , y  = snake.cola[#snake.cola].y - snake.velY} -- Añadimos una cola a la serpiente.
    if #snake.cola < 461 then -- Si la serpiente no tiene ocupado todo el area del juego, area es 19x19
      while contains(snake.cola , comida, 0) do -- Repetimos el siguiente codigo si la comida aparece encima de la serpiente
        -- damos una nueva posición random hasta que la comida esté fuera de la serpiente.
        comida.x = (math.random((area.w - area.x)/t)) * t + area.x
        comida.y = (math.random((area.h - area.y)/t)) * t + area.y
        estado = 1
      end
    else -- Si la serpiente ocupa todo el area entonces...
      estado = 3
      ganar = true -- Has ganado.
    end
  end
end


function mover()
  -- El sguiente for significa: Para i = cantidad de partes de la serpiente , repetimos el codigo hasta llegar que i = 0, restando -1 a i en cada repetición.
  for i = #snake.cola , 0 , -1 do -- Obtenemos cada parte de la serpiente, comenzando desde la cola hasta la cabeza, (en orden descendente, ej: 5,4,3,2,1,0)
    if i == 0 then -- snake.cola[0] es la cabeza de la serpiente, por lo que con ella controlamos el movimiento.
      snake.cola[0].x = snake.cola[0].x + snake.velX
      snake.cola[0].y = snake.cola[0].y + snake.velY
    else -- Para las demás hacemos que cada parte de la cola sea igual a la vecina anterior (i-1)
      snake.cola[i].x = snake.cola[i-1].x
      snake.cola[i].y = snake.cola[i-1].y
    end
  end
end


-- Debido a que en Lua no existe un has() para saber si alguna variable existe en una tabla,
-- He conseguido esta función en internet que hace lo mismo, con la diferencia que he añadido una variable num
-- Que utilizaremos en 2 variantes en nuestro juego.
function contains(tabla, val, num)
   for i=num,#tabla do
      if tabla[i].x == val.x and tabla[i].y == val.y then
         return true
      end
   end
   return false
end


function love.update(dt)
  if timer < 0.1 then -- Con esto controlaremos cada actualización de pantalla a 0.1 segundos
    timer = timer + dt
  elseif not perder and not ganar then -- El juego no continuará si has perdido o ganado
    timer = 0 -- Indica que el contador del tiempo de cada frame comienza
    comer()
    mover()
    if contains(snake.cola , snake.cola[0] , 1) then -- Revisamos si snake.cola tiene un valor igual a la cabeza(snake.cola[0]), añadimos 1 para que no cuente la cabeza.
      estado = 2
      perder = true -- Si ha colisionado entonces ha perdido
    end
    -- Aqui controlamos que la serpiente se mantenga dentro del area, reapareciendo en el lado opuesto.
    if snake.cola[0].x > area.w then
      snake.cola[0].x = area.x
    elseif snake.cola[0].x < area.x then
      snake.cola[0].x = area.w
    elseif snake.cola[0].y > area.h + t then
      snake.cola[0].y = area.y
    elseif snake.cola[0].y < area.y then
      snake.cola[0].y = area.h + t
    end
  end
end


function love.keypressed(key, scancode, isrepeat)
  if key == "up" and snake.velY ~= t then
    snake.velX = 0
    snake.velY = - t
  elseif key == "down" and snake.velY ~= -t then
    snake.velX = 0
    snake.velY = t
  elseif key == "left" and snake.velX ~= t then
    snake.velX = - t
    snake.velY = 0
  elseif key == "right" and snake.velX ~= -t then
    snake.velX = t
    snake.velY = 0
  elseif key == "r" and (perder or ganar) then -- Solo ejecuta si ha perdido o ganado.
    estado = 0
    snake.cola[0] = {x = area.x , y = area.y} -- Colocamos la cabeza de la serpiente en el lugar inicial
    for i = 1 , #snake.cola do -- Borramos todo el contenido de snake.cola menos la cabeza (snake.cola[0])
      snake.cola[i] = nil
    end
    -- Reiniciamos las variables del juego a su valor inicial...
    snake.velX = t
    snake.velY = 0
    comida.x = (math.random((area.w - area.x)/t)) * t + area.x
    comida.y = (math.random((area.h - area.y)/t)) * t + area.y
    perder = false
    ganar = false
  end
end
