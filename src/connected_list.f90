program main
    implicit none
    character(300) :: ifile, ofile, log_file
    character(20) :: obs_type !Temperature, Precipitation, Wind Speed, ...

    integer :: offset(2) !obs_typeで指定した観測種目の"統計の有無"と"統計接続情報"の開始バイト
    integer :: rec_len(2) !obs_typeで指定した観測種目の"統計の有無"と"統計接続情報"のバイト数

    character(263) :: amd_info
    character(10) :: sdate !現在の観測と接続されている期間の初日
    integer :: obs_flag_pre !1つ前の行の観測の有無: 0->なし, 1->あり
    integer :: cntd_flag !統計接続の有無
    integer :: i, ios

    namelist /nam/ obs_type, ifile, ofile, log_file
    read(5,nam)

    !--- ログを書き出すファイルを開く
    open(21, file=trim(log_file), action='write', status='replace')

    !--- 観測種目に関するデータの位置を取得
    call get_offset(obs_type,offset,rec_len)

    !--- 出力ファイルのヘッダーを書き出す
    call write_header(ofile)

    open(10, file=trim(ifile), action='read', status='old')
    read(10, '()') !1行目をスキップ
    read(10, '()') !2行目をスキップ

    sdate = '0000-00-00'
    obs_flag_pre = 0
    do i = 1, 10000, 1

        read(10, '(a)', iostat=ios) amd_info
        if (ios /= 0) exit

        !--- 観測されていない場合はスキップ
        if (amd_info(offset(1):offset(1)+rec_len(1)-1) == '0') then
            obs_flag_pre = 0
            cycle
        endif

        !--- 前の観測との接続をチェック(cntd_flag: 0->接続なし, 1->接続あり)
        call check_connection(amd_info,obs_type,offset,rec_len,cntd_flag)

        !--- 接続されていない場合はsdateを更新
        if (cntd_flag == 0) sdate = amd_info(216:225)
        
        !--- 同一地点において観測が開始された最初の行の場合はsdateを更新
        if (obs_flag_pre == 0 .and. cntd_flag == 1) then
            sdate = amd_info(216:225) 
        endif
        obs_flag_pre = 1

        !--- 現在の観測に関する行かどうかをチェック
        if (amd_info(227:236) == '9999-99-99') then
            !--- amd_infoの基本項目と, obs_typeに関する項目, sdateを書き出す
            call write_amedas_info(ofile,amd_info,sdate)
            write(21, '(a)') amd_info(1:26) // 'sdate = ' // sdate
        else
            cycle
        endif

    enddo !i

    contains

    subroutine write_header(ofile)
        implicit none
        character(300), intent(in) :: ofile

        open(20, file=trim(ofile), action='write', status='replace')
        write(20, '(a)') &
        &'Station Number,Station Name,Station Name,Station Name,&
        &Station Name of Snow,Station Name of Snow,Station Name of Snow,&
        &Latitude_Precipitation,Longitude_Precipitation,Altitude_Precipitation,&
        &Height of Anemometer,,,Latitude_Snow,Longitude_Snow,Altitude_Snow,&
        &Start Date,End Date'
        close(20)
    end subroutine write_header

    subroutine write_amedas_info(ofile,amd_info,sdate)
        implicit none
        character(300), intent(in) :: ofile
        character(263), intent(in) :: amd_info
        character(10), intent(in) :: sdate
        character(222) :: output_info

        output_info = amd_info(1:200) // ',' // sdate // ',' // amd_info(227:236)
        open(20, file=trim(ofile), action='write', status='old', position='append')
        write(20,'(a)') output_info
        close(20)
    end subroutine write_amedas_info

    subroutine check_connection(amd_info,obs_type,offset,rec_len,cntd_flag)
        implicit none
        character(263), intent(in) :: amd_info
        character(20), intent(in) :: obs_type
        integer, intent(in) :: offset(2), rec_len(2)
        integer, intent(out) :: cntd_flag
        integer :: st, en
        integer :: cntd_info
        
        st = offset(2)
        en = offset(2) + rec_len(2) - 1
        read(amd_info(st:en), '(I2)') cntd_info
        if (cntd_info == 0) then
            cntd_flag = 1
        else if (cntd_info == 1) then
            cntd_flag = 0
        else if (cntd_info == 4) then
            if (trim(obs_type) == 'Precipitation') cntd_flag = 0
            if (trim(obs_type) == 'WindSpeed') cntd_flag = 1
            if (trim(obs_type) == 'Temperature') cntd_flag = 1
            if (trim(obs_type) == 'Sunshine') cntd_flag = 1
            if (trim(obs_type) == 'Humidity') cntd_flag = 0
        else if (cntd_info == 5 .or. cntd_info == 6 .or. cntd_info ==7) then
            cntd_flag = 0
        endif
    end subroutine check_connection

    subroutine get_offset(obs_type,offset,rec_len)
        implicit none
        character(20), intent(in) :: obs_type
        integer, intent(out) :: offset(2), rec_len(2)

        !--- rec_lenはobs_typeによらない
        rec_len(1) = 1
        rec_len(2) = 2 

        !--- offsetはobs_typeによって異なる
        if (trim(obs_type) == 'Precipitation') then
            offset(1) = 202
            offset(2) = 244
        else if (trim(obs_type) == 'WindSpeed') then
            offset(1) = 204
            offset(2) = 247
        else if (trim(obs_type) == 'Temperature') then
            offset(1) = 206
            offset(2) = 250
        else if (trim(obs_type) == 'Sunshine') then
            offset(1) = 208
            offset(2) = 253
        else if (trim(obs_type) == 'Snow') then
            offset(1) = 210
            offset(2) = 256
        else if (trim(obs_type) == 'Humidity') then
            offset(1) = 214
            offset(2) = 262
        else
            print *, "Wrong observation type: ", trim(obs_type)
            stop
        endif
    end subroutine get_offset

end program