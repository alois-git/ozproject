functor
import
   Utils
   OS

export
   NewPokemoz
   NewRandomPokemoz

define

   HPLVLTABLE = lvl(5:20 6:22 7:24 8:26 9:28 10:30)
   XPLVLTABLE = lvl(6:5 7:12 8:20 9:30 10:50)
   MAXIMUMLVL = 10
   MINIMUMLVL = 5
   TPDMGTABLE = type(
                     grass:type(grass:2 fire:1 water:3)
                      fire:type(grass:3 fire:2 water:1)
                     water:type(grass:1 fire:3 water:2)
                  )

   fun {NewPokemoz Type Name Level}
      %% This object represents a Pokemoz (as defined in project statement)
      %% Available messages :
      %%    attackedby(POKEMOZ)
      %%       where POKEMOZ is an instance of Pokemoz
      %%    addxp(INTEGER)
      %%    isko(ret(RETURN))
      %%       where RETURN is an unbound variable (set to true or false)
      %%    heal
      %%    get(ATTRIBUTE ret(RETURN))
      %%       where ATTRIBUTE is one of the following : name, type, hpmax, hp, lx, xp
      %%       and RETURN is an unbound variable

      InitPokemoz = pokemoz(type:Type name:Name progress:{NewProgress Level})

      fun {FunPokemoz S Msg}
         case Msg
         of attackedby(Pkmz) then
            TA TD LA LD in
            {Send Pkmz get(lx ret(LA))}
            {Send S.progress get(lx ret(LD))}
            if {Abs {OS.rand}} mod 100 < {SuccessProba LA LD} then
               {Send Pkmz get(type ret(TA))}
               TD = S.type
               {Send S.progress removehp(TPDMGTABLE.TA.TD)}
            end
         [] addxp(A) then
            {Send S.progress addxp(A)}
         [] isko(ret(R)) then
            local IsKoAnswer in
               {Send S.progress get(hp ret(IsKoAnswer))}
               R = ( IsKoAnswer =< 0 )
            end
         [] heal then
            {Send S.progress heal}
         [] get(D ret(R)) then
            case D
            of type then R = S.type
            [] name then R = S.name
            else {Send S.progress get(D ret(R))}
            end
         end
         S % Actually, a Pokemoz state cannot change (except its progress)
      end

   in
      {Utils.newPortObject InitPokemoz FunPokemoz}
   end

   fun {NewRandomPokemoz}
      PkmzType = type(grass fire water)
      PkmzName = names(
                     namecount: 6
                     grass: names("Bulbasoz" "Ozdish" "Bellsproz" "Tangeloz" "Ozeggcute" "Paroz")
                     fire: names("Charmandoz" "Vulpoz" "Ozlithe" "Ponytoz" "Ozgmar" "Flareoz")
                     water: names("Oztirtle" "Ozduck" "Poliwoz" "Lugioz" "Ozellder" "Krabboz") % La dernière est drôle
                  )
      T N L
   in
      T = ({Abs {OS.rand}} mod 3) + 1
      N = ({Abs {OS.rand}} mod PkmzName.namecount) +1
      L = ({Abs {OS.rand}} mod (MAXIMUMLVL - MINIMUMLVL)) + MINIMUMLVL
      {NewPokemoz PkmzType.T PkmzName.(PkmzType.T).N L}
   end

   fun {NewProgress Level}
      %% This private object allows to update a Pokemoz status
      %% Available messages :
      %%    removehp(INTEGER)
      %%    heal
      %%    addxp(INTEGER)
      %%    get(ATTRIBUTE ret(RETURN))
      %%       where ATTRIBUTE in one of the following : hpmax, hp, lx, xp
      %%       and RETURN is an unbound variable

      InitProgress = progress(hpmax:HPLVLTABLE.Level hp:HPLVLTABLE.Level lx:Level xp:0)

      fun {FunProgress S Msg}
         case Msg
         of removehp(D) then
            progress(hpmax:S.hpmax hp:(S.hp-D) lx:S.lx xp:S.xp)
         [] heal then
            progress(hpmax:S.hpmax hp:S.hpmax lx:S.lx xp:S.xp)
         [] addxp(A) then
            if S.lx < MAXIMUMLVL then
               if S.xp+A > XPLVLTABLE.(S.lx+1) then
                  progress(hpmax:HPLVLTABLE.(S.lx+1) hp:HPLVLTABLE.(S.lx+1) lx:(S.lx+1) xp:(S.xp+A))
               else
                  progress(hpmax:S.hpmax hp:S.hp lx:S.lx xp:(S.xp+A))
               end
            else % Lx = 10
               if S.xp+A > XPLVLTABLE.(S.lx) then
                  progress(hpmax:HPLVLTABLE.(S.lx) hp:HPLVLTABLE.(S.lx) lx:S.lx xp:((S.xp+A) mod XPLVLTABLE.(S.lx)))
               else
                  progress(hpmax:S.hpmax hp:S.hp lx:S.lx xp:(S.xp+A))
               end
            end
         [] get(D ret(R)) then
            % Possible values for D : hpmax, hp, lx, xp
            R = S.D
            S
         end
      end

   in
      {Utils.newPortObject InitProgress FunProgress}
   end

   fun {SuccessProba LA LD}
      (6 + LA - LD) * 9
   end

end
