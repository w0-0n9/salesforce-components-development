import { LightningElement } from 'lwc';

export default class SalesforceGoogleMap extends LightningElement {
    
    mapMarkers = [
        {
            location: {
                Street: '35 Olympic-ro, Songpa-gu',
                City: 'Seoul',
            },

            title: '삼성SDS (잠실)',
            description:
                "Tel : 02-6155-3114(W), 02-6155-0102(E), E-Mail : contact.sds@samsung.com \n Website : https://www.samsungsds.com/kr"
        },

        {
            location: {
                Street: '17, Changeop-ro, Sujeong-gu, Seongnam-si',
                City: 'Gyeonggi-do',
            },

            title: '삼성SDS 판교 IT Campus',
            description:
                '[13449] 경기도 성남시 수정구 창업로 17(시흥동) 판교아이스퀘어\nTel : 031-5178-0114',
        },

        {
            location: {
                Street: '10, Daewangpangyo-ro 606beon-gil, Bundang-gu, Seongnam-si',
                City: 'Gyeonggi-do',
            },

            title: '삼성SDS 판교 물류 Campus',
            description:
                '[13530] 경기도 성남시 분당구 대왕판교로 606번길 10 (백현동) 알파리움타워 I\nTel : 02-6484-0114\nE-Mail : cello@samsung.com',
        },

        {
            location: {
                Street: '56, Seongchon-gil, Seocho-gu',
                City: 'Seoul',
            },

            title: '삼성SDS 서울R&D캠퍼스',
            description:
                '[06765] 서울시 서초구 성촌길 56 (성촌동) E타워\nTel : (SDS 대표번호) 02-6155-3618, (E타워 대표번호) 02-6147-9904',
        },

        {
            location: {
                Street: '24, World Cup buk-ro 60-gil, Mapo-gu',
                City: 'Seoul',
            },

            title: '삼성SDS 상암 데이터센터',
            description:
                '[03922] 서울 특별시 마포구 월드컵북로 60길 24\nTel : 02-6440-7114',
        },

        {
            location: {
                Street: '10, Samsung-ro 168beon-gil, Yeongtong-gu, Suwon-si',
                City: 'Gyeonggi-do',
            },

            title: '삼성SDS 수원 데이터센터',
            description:
                '[16676] 경기도 수원시 영통구 삼성로 168번길 10 (매탄3동)\nTel : 031-8006-5114',
        },

        {
            location: {
                Street: '409-14, Yetgyeongchun-ro, Chuncheon-si',
                City: 'Gangwon-do',
            },

            title: '삼성SDS 춘천 데이터센터',
            description:
                '[24239] 강원도 춘천시 옛경춘로 409-14 (칠전동), Tel : 033-913-9114',
        },

        {
            location: {
                Street: '14, Dongtan-daero 9na-gil, Hwaseong-si',
                City: 'Gyeonggi-do',
            },

            title: '삼성SDS 동탄 데이터센터',
            description:
                '[18488] 경기도 화성시 동탄대로9나길 14(송동), Tel : 02-509-0114',
        },

        {
            location: {
                Street: '302, 3gongdan 3-ro, Gumi-si',
                City: 'Gyeongsangbuk-do',
            },

            title: '삼성SDS 구미 데이터센터',
            description:
                '[39388] 경상북도 구미시 3공단3로 302 (임수동), Tel : 054-479-3114',
        },
    ];
    zoomLevel = 8;
    listView = 'visible';
}